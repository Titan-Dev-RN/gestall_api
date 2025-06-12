class Api::V1::InformacoesLojasController < ApplicationController
  before_action :authorize_super_admin, only: [:create, :update, :destroy]
  before_action :set_loja, only: [:show, :update, :destroy, :reativar]

  # GET /api/v1/informacoes_lojas
  def index
    @lojas = InformacaoLoja.all
    render json: @lojas, status: :ok
  end

  # GET /api/v1/informacoes_lojas/1
  def show
    render json: @loja
  end

  # POST /api/v1/informacoes_lojas
  def create
    @loja = InformacaoLoja.new(loja_params)
    @loja.token_integracao = SecureRandom.hex(16)
    @loja.data_de_entrada = Time.current
    @loja.ativo = true

    if @loja.save
      begin
        criar_banco_loja(@loja)
        criar_admin_padrao(@loja)
        
        render json: {
          message: 'Loja criada com sucesso',
          loja: @loja,
          database_name: "gestall_#{@loja.id}"
        }, status: :created
      rescue => e
        @loja.update(ativo: false)
        render json: {
          error: 'Falha na configuração',
          details: e.message,
          solution: 'Contacte o administrador do sistema'
        }, status: :internal_server_error
      end
    else
      render json: { errors: @loja.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/informacoes_lojas/1
  def update
    if @loja.update(loja_params)
      render json: @loja
    else
      render json: @loja.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/informacoes_lojas/1
  def destroy
    @loja.update(ativo: false)
    render json: { message: 'Loja desativada com sucesso' }, status: :ok
  end

  # POST /api/v1/informacoes_lojas/1/reativar
  def reativar
    @loja.update(ativo: true)
    render json: { message: 'Loja reativada com sucesso' }, status: :ok
  end

  private

  def set_loja
    @loja = InformacaoLoja.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Loja não encontrada' }, status: :not_found
  end

  def loja_params
    params.require(:informacao_loja).permit(
      :nome_da_loja, :nome_dono, :forma_de_pagamento, :endereco, 
      :cidade, :estado, :cnpj, :telefone, :email, :plano_contratado,
      :data_vencimento_plano, :configuracoes
    )
  end

  def authorize_super_admin
    unless @current_user&.super_admin?
      render json: { error: 'Acesso não autorizado' }, status: :forbidden
    end
  end

  def criar_banco_loja(loja)
    main_config = ActiveRecord::Base.connection_db_config.configuration_hash
    
    begin
      # Criar conexão temporária com PG
      temp_conn = PG.connect(
        dbname: 'postgres',
        user: main_config[:username],
        password: main_config[:password],
        host: main_config[:host]
      )
      
      # Criar o banco de dados
      temp_conn.exec("CREATE DATABASE gestall_#{loja.id} ENCODING 'UTF8' TEMPLATE template0")
      
      config = {
        adapter: 'postgresql',
        encoding: 'unicode',
        pool: 5,
        username: main_config[:username],
        password: main_config[:password],
        host: main_config[:host],
        database: "gestall_#{loja.id}"
      }

      config_file = Rails.root.join('config', 'databases', "#{loja.id}.yml")
      FileUtils.mkdir_p(File.dirname(config_file))
      File.write(config_file, config.to_yaml)

      ActiveRecord::Base.establish_connection(config)
      ActiveRecord::Tasks::DatabaseTasks.migrate
      
    rescue PG::Error => e
      Rails.logger.error "Falha ao criar banco para loja #{loja.id}: #{e.message}"
      raise "Falha ao criar banco de dados: #{e.message}"
    ensure
      temp_conn&.close
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    end
  end

  def criar_admin_padrao(loja)
    config = carregar_configuracao_banco(loja)
    
    begin
      Rails.logger.info "Criando usuário admin para loja #{loja.id}"
      
      # Conectar ao banco da loja
      ActiveRecord::Base.establish_connection(config)
      
      # Verificar se o usuário já existe
      admin_email = "admin@#{loja.nome_da_loja.parameterize}.com"
      
      unless Usuario.exists?(email: admin_email)
        Usuario.create!(
          email: admin_email,
          password: 'senha123',
          password_confirmation: 'senha123',
          tipo_acesso: 'admin_loja',
          ativo: true,
          id_loja: loja.id
        )
        
        Rails.logger.info "Usuário admin criado: #{admin_email}"
      else
        Rails.logger.info "Usuário admin já existe: #{admin_email}"
      end
      
    rescue => e
      Rails.logger.error "Erro ao criar admin para loja #{loja.id}: #{e.message}"
      raise "Falha ao criar usuário administrador: #{e.message}"
    ensure
      # Restaurar conexão principal
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    end
  end

  def salvar_configuracao_banco(loja, main_config)
    config = {
      adapter: 'postgresql',
      encoding: 'unicode',
      pool: ENV.fetch('RAILS_MAX_THREADS', 5).to_i,
      username: main_config[:username],
      password: main_config[:password],
      host: main_config[:host] || 'localhost',
      port: main_config[:port] || 5432,
      database: "gestall_#{loja.id}"
    }

    # Criar diretório se não existir
    config_dir = Rails.root.join('config', 'databases')
    FileUtils.mkdir_p(config_dir)
    
    # Salvar arquivo de configuração
    config_file = config_dir.join("#{loja.id}.yml")
    File.write(config_file, config.to_yaml)
    
    Rails.logger.info "Configuração salva em: #{config_file}"
  end

  def carregar_configuracao_banco(loja)
    config_file = Rails.root.join('config', 'databases', "#{loja.id}.yml")
    
    unless File.exist?(config_file)
      raise "Arquivo de configuração não encontrado: #{config_file}"
    end
    
    YAML.load_file(config_file)
  end

  def database_info(loja)
    {
      database_name: "gestall_#{loja.id}",
      config_file: "config/databases/#{loja.id}.yml",
      admin_email: "admin@#{loja.nome_da_loja.parameterize}.com",
      admin_password: 'senha123'
    }
  end
end