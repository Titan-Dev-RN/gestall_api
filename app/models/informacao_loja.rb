class InformacaoLoja < ApplicationRecord
  has_many :usuarios
  has_many :funcionarios
  has_many :estoquedeprodutos
  has_many :fornecedores
  has_many :clientes
  has_many :vendas
  has_many :assinaturas
  has_many :notas_fiscais
  has_many :transacoes_pagamento, through: :assinaturas

  after_create :criar_infraestrutura_loja, if: -> { Rails.env.development? || Rails.env.production? }

  validates :cnpj, presence: true, uniqueness: true
  validates :nome_da_loja, :email, presence: true

  def estoque_produtos
    EstoqueDeProduto.where(informacao_loja_id: id)
  end

  def criar_infraestrutura_loja
    criar_banco_dados
    duplicar_para_banco_da_loja
    criar_admin_padrao
  end

  private

  def carregar_configuracao_banco
    config_file = Rails.root.join('config', 'databases', "#{token_integracao}.yml")
    
    unless File.exist?(config_file)
      raise "Arquivo de configuração não encontrado: #{config_file}"
    end
    
    YAML.load_file(config_file)
  end

  def criar_banco_dados
    main_config = ActiveRecord::Base.connection_db_config.configuration_hash
    
    begin
      temp_conn = PG.connect(
        dbname: 'postgres',
        user: main_config[:username],
        password: main_config[:password],
        host: main_config[:host]
      )
      
      db_name = "gestall_#{token_integracao.parameterize.underscore}"
      temp_conn.exec("CREATE DATABASE #{db_name} ENCODING 'UTF8' TEMPLATE template0")
      
      config = {
        adapter: 'postgresql',
        encoding: 'unicode',
        pool: 5,
        username: main_config[:username],
        password: main_config[:password],
        host: main_config[:host],
        database: db_name
      }

      config_file = Rails.root.join('config', 'databases', "#{token_integracao}.yml")
      FileUtils.mkdir_p(File.dirname(config_file))
      File.write(config_file, config.to_yaml)

      ActiveRecord::Base.establish_connection(config)
      ActiveRecord::Tasks::DatabaseTasks.migrate
      
    rescue PG::Error => e
      Rails.logger.error "Falha ao criar banco para loja #{token_integracao}: #{e.message}"
      raise "Falha ao criar banco de dados: #{e.message}"
    ensure
      temp_conn&.close
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    end
  end

  def duplicar_para_banco_da_loja
    config = carregar_configuracao_banco
    ActiveRecord::Base.establish_connection(config)

    unless ActiveRecord::Base.connection.table_exists?('informacao_lojas')
      ActiveRecord::Tasks::DatabaseTasks.migrate
    end

    InformacaoLoja.create!(attributes.except('id', 'created_at', 'updated_at'))
  rescue => e
    Rails.logger.error "Falha ao duplicar InformacaoLoja: #{e.message}"
    raise if Rails.env.development?
  ensure
    ActiveRecord::Base.establish_connection(Rails.env.to_sym)
  end

  def criar_admin_padrao
    config = carregar_configuracao_banco
    admin_email = "admin@#{nome_da_loja.parameterize}.com"
    senha = SecureRandom.hex(8)

    # Criar no banco principal
    ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    user = Usuario.create!(
      nome: "Admin #{nome_da_loja}",
      email: admin_email,
      password: senha,
      password_confirmation: senha,
      tipo_acesso: 'admin_loja',
      ativo: true,
      token_integracao_loja: token_integracao
    )

    # Criar no banco da loja
    ActiveRecord::Base.establish_connection(config)
    
    unless InformacaoLoja.exists?(token_integracao: token_integracao)
      InformacaoLoja.create!(attributes.except('id', 'created_at', 'updated_at'))
    end

    unless Usuario.exists?(email: admin_email)
      Usuario.create!(
        id: user.id,
        nome: "Admin #{nome_da_loja}",
        email: admin_email,
        password: senha,
        password_confirmation: senha,
        tipo_acesso: 'admin_loja',
        ativo: true,
        token_integracao_loja: token_integracao
      )
    end
  rescue => e
    Rails.logger.error "Erro ao criar admin: #{e.message}"
    raise
  ensure
    ActiveRecord::Base.establish_connection(Rails.env.to_sym)
  end
end