TOKEN_LOJA_DEV = "gestall_dev"

loja = InformacaoLoja.find_or_create_by(cnpj: "00.000.000/0001-00") do |l|
  l.nome_da_loja         = "Gestall Dev"
  l.nome_dono            = "Admin"
  l.forma_de_pagamento   = "pix"
  l.endereco             = "Rua Dev, 1"
  l.cidade               = "São Paulo"
  l.estado               = "SP"
  l.telefone             = "(11) 00000-0000"
  l.email                = "loja@gestall.com"
  l.plano_contratado     = "basico"
  l.data_vencimento_plano = Date.today + 1.year
  l.ativo                = true
  l.token_integracao     = TOKEN_LOJA_DEV
end

Usuario.find_or_create_by(email: "admin@gestall.com") do |u|
  u.nome                    = "Admin Gestall"
  u.password                = "123456"
  u.password_confirmation   = "123456"
  u.tipo_acesso             = :super_admin
  u.ativo                   = true
  u.token_identificacao     = SecureRandom.hex(16)
  u.token_integracao_loja   = loja.token_integracao
  u.password_reset_required = false
end

Usuario.find_or_create_by(email: "adminloja@gestall.com") do |u|
  u.nome                    = "Admin Loja Dev"
  u.password                = "123456"
  u.password_confirmation   = "123456"
  u.tipo_acesso             = :admin_loja
  u.ativo                   = true
  u.token_identificacao     = SecureRandom.hex(16)
  u.token_integracao_loja   = loja.token_integracao
  u.password_reset_required = false
end

puts "Loja seed:         Gestall Dev (token: #{TOKEN_LOJA_DEV})"
puts "Super admin:       admin@gestall.com / 123456"
puts "Admin loja:        adminloja@gestall.com / 123456"

# Lista completa de permissões do sistema (nome deve corresponder ao PERMISSOES_POR_ACAO)
PERMISSOES_SEED = [
  { nome: 'cliente_listar',              descricao: 'Cliente listar' },
  { nome: 'cliente_cadastrar',           descricao: 'Cliente cadastrar' },
  { nome: 'cliente_atualizar',           descricao: 'Cliente atualizar' },
  { nome: 'cliente_desativar',           descricao: 'Cliente desativar' },
  { nome: 'cliente_ativar_desativar',    descricao: 'Cliente ativar desativar' },
  { nome: 'fornecedor_listar',           descricao: 'Fornecedor listar' },
  { nome: 'fornecedor_cadastrar',        descricao: 'Fornecedor cadastrar' },
  { nome: 'fornecedor_atualizar',        descricao: 'Fornecedor atualizar' },
  { nome: 'fornecedor_desativar',        descricao: 'Fornecedor desativar' },
  { nome: 'fornecedor_ativar_desativar', descricao: 'Fornecedor ativar desativar' },
  { nome: 'funcionario_listar',          descricao: 'Funcionario listar' },
  { nome: 'funcionario_registrar',       descricao: 'Funcionario registrar' },
  { nome: 'funcionario_desativar',       descricao: 'Funcionario desativar' },
  { nome: 'produto_visualizar_estoque',   descricao: 'Produto visualizar estoque' },
  { nome: 'produto_cadastrar',            descricao: 'Produto cadastrar' },
  { nome: 'produto_atualizar',            descricao: 'Produto atualizar' },
  { nome: 'produto_ativar_desativar',     descricao: 'Produto ativar desativar' },
  { nome: 'produto_adicionar_quantidade', descricao: 'Produto adicionar quantidade' },
  { nome: 'produto_remover_quantidade',   descricao: 'Produto remover quantidade' },
  { nome: 'produto_cadastrar_categoria',  descricao: 'Produto cadastrar categoria' },
  { nome: 'produto_visualizar_categorias', descricao: 'Produto visualizar categorias' },
  { nome: 'vender_consultar',             descricao: 'Vender consultar' },
  { nome: 'vender_iniciar_finalizar',     descricao: 'Vender iniciar finalizar' },
  { nome: 'vender_adicionar_remover',     descricao: 'Vender adicionar remover' },
  { nome: 'vender_cancelar',              descricao: 'Vender cancelar' },
  { nome: 'vender_descontos',             descricao: 'Vender descontos' },
  { nome: 'sessao_listar',                descricao: 'Sessao listar' },
  { nome: 'sessao_iniciar',               descricao: 'Sessao iniciar' },
  { nome: 'sessao_encerrar',              descricao: 'Sessao encerrar' },
  { nome: 'sessao_verificar',             descricao: 'Sessao verificar' },
  { nome: 'minha_loja_visualizar',        descricao: 'Minha loja visualizar' },
  { nome: 'minha_loja_atualizar',         descricao: 'Minha loja atualizar' },
  { nome: 'conta_listar',                 descricao: 'Conta listar' },
  { nome: 'conta_cadastrar',              descricao: 'Conta cadastrar' },
  { nome: 'conta_atualizar',              descricao: 'Conta atualizar' },
  { nome: 'conta_desativar',              descricao: 'Conta desativar' },
  { nome: 'servico_listar',               descricao: 'Servico listar' },
  { nome: 'servico_cadastrar',            descricao: 'Servico cadastrar' },
  { nome: 'servico_atualizar',            descricao: 'Servico atualizar' },
  { nome: 'servico_desativar',            descricao: 'Servico desativar' },
  { nome: 'servico_ativar_desativar',     descricao: 'Servico ativar desativar' },
  { nome: 'movimentacao_listar',          descricao: 'Movimentacao listar' },
  { nome: 'super_admin',                  descricao: 'Super admin' },
].freeze

InformacaoLoja.find_each do |loja|
  token = loja.token_integracao
  criadas = 0

  PERMISSOES_SEED.each do |p|
    next if Permissao.exists?(nome: p[:nome], token_integracao_loja: token)
    Permissao.create!(nome: p[:nome], descricao: p[:descricao], token_integracao_loja: token)
    criadas += 1
  end

  puts "Permissões para '#{loja.nome_da_loja}' (#{token}): #{criadas} criadas."
end