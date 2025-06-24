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
    YAML.load_file(config_file)
  end

  def criar_banco_dados
    main_config = ActiveRecord::Base.connection_db_config.configuration_hash
    
    # Configurações padrão para conexão administrativa
    conn_params = {
      dbname: 'postgres', # Conexão ao banco padrão do PostgreSQL
      user: main_config[:username] || main_config[:user] || 'postgres',
      password: main_config[:password],
      host: main_config[:host] || 'localhost',
      port: main_config[:port] || 5432
    }.compact

    begin
      # Conectar ao PostgreSQL para criar o banco
      conn = PG.connect(conn_params)
      
      # Nome do banco de dados da loja
      db_name = "gestall_#{token_integracao.parameterize.underscore}"
      
      # Verificar se o banco já existe
      result = conn.exec("SELECT 1 FROM pg_database WHERE datname = '#{db_name}'")
      
      if result.ntuples.zero?
        conn.exec("CREATE DATABASE #{db_name} ENCODING 'UTF8' TEMPLATE template0")
        Rails.logger.info "Banco de dados #{db_name} criado com sucesso"
      else
        Rails.logger.info "Banco de dados #{db_name} já existe"
      end
      
      # Configuração para uso com ActiveRecord
      config = {
        adapter: 'postgresql',
        encoding: 'unicode',
        pool: 5,
        username: conn_params[:user],
        password: conn_params[:password],
        host: conn_params[:host],
        port: conn_params[:port],
        database: db_name
      }

      # Salvar configuração no arquivo YML
      config_file = Rails.root.join('config', 'databases', "#{token_integracao}.yml")
      FileUtils.mkdir_p(File.dirname(config_file))
      File.write(config_file, config.to_yaml)

    rescue PG::Error => e
      Rails.logger.error "Falha ao criar banco: #{e.message}"
      raise "Falha ao criar banco de dados: #{e.message}"
    ensure
      conn&.close
    end
  end

  def duplicar_para_banco_da_loja
    config = carregar_configuracao_banco
    
    # Conexão direta com PG usando a configuração do banco recém-criado
    conn_params = {
      dbname: config['database'],
      user: config['username'] || config['user'],
      password: config['password'],
      host: config['host'] || 'localhost',
      port: config['port'] || 5432
    }.compact

    begin
      # Executar migrações via linha de comando
      database_url = "postgresql://#{conn_params[:user]}:#{conn_params[:password]}@#{conn_params[:host]}:#{conn_params[:port]}/#{conn_params[:dbname]}"
      system({"RAILS_ENV" => Rails.env, "DATABASE_URL" => database_url}, "bundle exec rails db:migrate")
      
      # Conexão para inserir os dados
      conn = PG.connect(conn_params)
      
      # Construir query SQL para inserir a loja
      attrs = attributes.except('id', 'created_at', 'updated_at')
      columns = attrs.keys.join(', ')
      values = attrs.values.map { |v| conn.escape_literal(v) }.join(', ')
      
      conn.exec("INSERT INTO informacao_lojas (#{columns}) VALUES (#{values})")
      
      Rails.logger.info "Loja duplicada no banco tenant #{config['database']}"
    rescue PG::Error => e
      Rails.logger.error "Erro ao configurar banco tenant: #{e.message}"
      raise "Falha ao configurar banco tenant: #{e.message}"
    ensure
      conn&.close
    end
  end

  def criar_admin_padrao
    admin_email = "admin@#{nome_da_loja.parameterize}.com"
    senha = SecureRandom.hex(8)

    # Criar no banco principal
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
    config = carregar_configuracao_banco
    conn = PG.connect(config)

    begin
      # Construir query SQL para usuário
      user_attrs = user.attributes.except('id', 'created_at', 'updated_at')
      columns = user_attrs.keys.join(', ')
      values = user_attrs.values.map { |v| conn.escape_literal(v) }.join(', ')
      
      # Inserir usuário
      conn.exec("INSERT INTO usuarios (#{columns}) VALUES (#{values})")
      
      Rails.logger.info "Admin criado no banco tenant"
    rescue PG::Error => e
      Rails.logger.error "Erro ao criar admin: #{e.message}"
    ensure
      conn&.close
    end
  end
end