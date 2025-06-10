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
    ActiveRecord::Base.transaction do
      @loja = InformacaoLoja.new(loja_params)
      @loja.token_integracao = SecureRandom.hex(16)
      @loja.data_de_entrada = Time.current
      @loja.ativo = true

      if @loja.save
        criar_banco_loja(@loja)
        
        criar_admin_padrao(@loja)
        
        render json: {
          message: 'Loja criada com sucesso',
          loja: @loja,
          database_config: database_config(@loja)
        }, status: :created
      else
        render json: { errors: @loja.errors.full_messages }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  rescue => e
    render json: { 
      error: 'Falha ao criar loja',
      details: e.message 
    }, status: :internal_server_error
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
    unless @current_user.super_admin?
      render json: { error: 'Acesso não autorizado' }, status: :forbidden
    end
  end

  def criar_banco_loja(loja)
    # Conexão temporária sem transação
    conn = ActiveRecord::Base.connection_pool.checkout
    conn.execute("CREATE DATABASE gestall_#{loja.id}")

    # Configuração do banco de dados
    config = {
      adapter: 'postgresql',
      encoding: 'unicode',
      pool: 5,
      username: 'postgres',
      password: loja.cnpj,
      host: 'localhost',
      database: "gestall_#{loja.id}"
    }

    config_file = Rails.root.join('config', 'databases', "#{loja.id}.yml")
    FileUtils.mkdir_p(File.dirname(config_file))
    File.write(config_file, config.to_yaml)

    ActiveRecord::Base.establish_connection(config)
    if ActiveRecord::Base.respond_to?(:connection) && ActiveRecord::Base.connection.respond_to?(:migration_context)
      ActiveRecord::Base.connection.migration_context.migrate
    else
      ActiveRecord::MigrationContext.new('db/migrate/').migrate
    end
    
    # Volta para conexão principal
    ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    ActiveRecord::Base.connection_pool.checkin(conn)
  rescue => e
    Rails.logger.error "Falha ao criar banco para loja #{loja.id}: #{e.message}"
    raise
  end

  def criar_admin_padrao(loja)
    config = YAML.load_file(Rails.root.join('config', 'databases', "#{loja.id}.yml"))
    ActiveRecord::Base.establish_connection(config)

    Usuario.create!(
      email: "admin@#{loja.nome_da_loja.parameterize}.com",
      password: 'senha123',
      password_confirmation: 'senha123',
      tipo_acesso: 'admin_loja',
      ativo: true,
      id_loja: loja.id
    )

    # Volta para a conexão principal
    ActiveRecord::Base.establish_connection(Rails.env.to_sym)
  rescue => e
    Rails.logger.error "Falha ao criar admin padrão para loja #{loja.id}: #{e.message}"
    raise
  end

  def database_config(loja)
    {
      database_name: "gestall_#{loja.id}",
      config_file: "config/databases/#{loja.id}.yml",
      admin_email: "admin@#{loja.nome_da_loja.parameterize}.com",
      admin_password: 'senha123'
    }
  end
end