# db/seeds.rb
require 'faker'
Faker::Config.locale = 'pt-BR'

# Limpar dados existentes


# 1. Criar Plano
puts "Criando plano..."
plano = Plano.create!(
  nome: "Premium",
  descricao: "Plano completo com todos os recursos",
  valor_mensal: 299.90,
  recursos: "Gestão de estoque, vendas, relatórios avançados, suporte 24/7"
)

# 2. Criar Loja
puts "Criando loja..."
loja = InformacaoLoja.create!(
  nome_da_loja: "Loja do Seu Zé",
  nome_dono: "José da Silva",
  forma_de_pagamento: "Cartão/Dinheiro/PIX",
  endereco: Faker::Address.street_address,
  cidade: Faker::Address.city,
  estado: Faker::Address.state_abbr,
  data_de_entrada: Time.current,
  cnpj: Faker::Company.brazilian_company_number,
  telefone: Faker::PhoneNumber.cell_phone,
  email: "contato@#{Faker::Internet.domain_name}",
  plano_contratado: "Premium",
  data_vencimento_plano: 1.year.from_now,
  ativo: true,
  token_integracao: SecureRandom.hex(20),
  configuracoes: { tema: "claro", notificacoes: true }
)

# 3. Criar Assinatura
puts "Criando assinatura..."
assinatura = Assinatura.create!(
  informacao_loja_id: loja.id,
  plano_id: plano.id,
  data_inicio: Date.today,
  data_vencimento: 1.year.from_now,
  status: "ativo",
  gateway_pagamento: "Pagar.me",
  id_externo_gateway: "assin_#{SecureRandom.alphanumeric(16)}"
)

# 4. Criar Usuários (Admin e Vendedor)
puts "Criando usuários..."

# Verifique como seu modelo Usuario espera a senha (adaptar conforme necessário)
admin = Usuario.create!(
  nome: "Admin Loja",
  email: "admin@loja.com",
  password: "senha123",
  password_confirmation: "senha123", 
  id_loja: loja.id,
  tipo_acesso: "admin_loja",
  ativo: true,
  role: "admin"
)

vendedor = Usuario.create!(
  nome: "Carlos Vendedor",
  email: "vendedor@loja.com",
  password: "senha123",
  password_confirmation: "senha123",
  id_loja: loja.id,
  tipo_acesso: "funcionario",
  ativo: true,
  role: "vendedor" 
)

# 5. Criar Funcionário (Vendedor)
puts "Criando funcionário vendedor..."
funcionario = Funcionario.create!(
  informacao_loja_id: loja.id,
  usuario_id: vendedor.id,
  nome: "Carlos Vendedor",
  cpf: 13499615401,
  rg: 13499615401,
  data_nascimento: Faker::Date.birthday(min_age: 18, max_age: 65),
  cargo: "Vendedor",
  salario_base: 2500.00,
  comissao_percentual: 5.0,
  data_admissao: 6.months.ago,
  ativo: true,
  telefone: Faker::PhoneNumber.cell_phone
)

# Atualizar usuário do vendedor com id_funcionario
vendedor.update(id_funcionario: funcionario.id)

# 6. Criar Fornecedores
puts "Criando fornecedores..."
3.times do
  Fornecedor.create!(
    informacao_loja_id: loja.id,  # Usando o nome exato da coluna
    nome: Faker::Company.name,
    cnpj: Faker::Company.brazilian_company_number,
    contato: Faker::Name.name,
    telefone: Faker::PhoneNumber.cell_phone,
    email: Faker::Internet.email,
    endereco: Faker::Address.full_address
  )
rescue ActiveRecord::RecordNotUnique => e
  puts "CNPJ duplicado gerado: #{e.message}. Gerando novo..."
  retry
end
categoria = Categoria.create!(nome: "generico")
# 7. Criar Produtos no Estoque
puts "Criando produtos..."
fornecedores = Fornecedor.all

15.times do |i|
  EstoqueDeProduto.create!(
    informacao_loja_id: loja.id,
    nome_do_produto: Faker::Commerce.product_name,
    categoria_do_produto: categoria.id,
    tipo_do_produto: ["Unidade", "Kg", "Litro", "Pacote"].sample,
    quantidade_em_estoque: Faker::Number.between(from: 10, to: 100),
    quantidade_minima: 5,
    quantidade_maxima: 150,
    preco_de_venda: Faker::Commerce.price(range: 5..500.0),
    fornecedor_id: fornecedores.sample.id,
    codigo_barras: Faker::Barcode.ean(13),
    codigo_interno: "PROD#{i+1000}",
    unidade_medida: ["UN", "KG", "LT"].sample,
    peso: Faker::Measurement.weight,
    marca: Faker::Company.name,
    ativo: true
  )
end

# 8. Criar Clientes
puts "Criando clientes..."
10.times do
  Cliente.create!(
    informacao_loja_id: loja.id,
    nome: Faker::Name.name,
    cpf_cnpj: 13499615401,
    telefone: Faker::PhoneNumber.cell_phone,
    email: Faker::Internet.email,
    endereco: Faker::Address.full_address,
    data_cadastro: Faker::Date.between(from: 1.year.ago, to: Date.today)
  )
end

# 9. Criar Vendas com Itens
puts "Criando vendas..."
clientes = Cliente.all
produtos = EstoqueDeProduto.all

5.times do
  venda = Venda.create!(
    informacao_loja_id: loja.id,
    cliente_id: clientes.sample.id,
    usuario_id: vendedor.id,
    data_venda: Faker::Time.between(from: 1.month.ago, to: Time.now),
    valor_total: 0, # Será calculado
    desconto: Faker::Number.between(from: 0, to: 50),
    status: ["pendente", "finalizada", "cancelada"].sample,
    forma_pagamento: ["Dinheiro", "Cartão", "PIX"].sample,
    observacoes: Faker::Lorem.sentence
  )

  # Adicionar itens à venda
  num_itens = rand(1..5)
  valor_total = 0

  num_itens.times do
    produto = produtos.sample
    quantidade = rand(1..3)
    preco_unitario = produto.preco_de_venda
    desconto_item = rand(0..10)
    valor_item = (preco_unitario * quantidade) * (100 - desconto_item) / 100
  
    ItemVenda.create!(
      venda_id: venda.id,
      estoque_de_produto_id: produto.id,  # Usando o nome correto da coluna
      quantidade: quantidade,
      valor_unitario: preco_unitario,
      desconto: desconto_item,
      valor_total: valor_item
    )
  
    valor_total += valor_item
  end

  # Aplicar desconto geral na venda
  valor_total = valor_total * (100 - venda.desconto) / 100 if venda.desconto > 0
  
  # Atualizar valor total da venda
  venda.update!(valor_total: valor_total.round(2))
end

puts "Seed concluído com sucesso!"
puts "Credenciais para login:"
puts "Admin: admin@loja.com / senha123"
puts "Vendedor: vendedor@loja.com / senha123"