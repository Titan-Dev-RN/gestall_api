class Api::V1::FuncionariosController < ApplicationController
  before_action :set_funcionario, only: [:show, :update, :destroy]

  def index
    funcionarios = Funcionario.where(
      informacao_loja_token: @current_user.token_integracao_loja
    ).includes(:usuario)
    
    render json: funcionarios, include: [:usuario]
  end

  def show
    render json: @funcionario, include: [:usuario]
  end

  def create
    ActiveRecord::Base.transaction do
      # 1. Cria o funcionário no tenant database usando o método que funciona
      tenant_creation = create_in_tenant_db
      
      unless tenant_creation[:success]
        raise ActiveRecord::Rollback, tenant_creation[:error]
      end
      
      @funcionario = tenant_creation[:funcionario]

      # 2. Criação de usuário (se necessário)
      if params[:funcionario][:criar_usuario].to_s.downcase == 'true'
        create_user_for_funcionario(@funcionario)
      end

      render json: @funcionario, status: :created
    rescue ActiveRecord::Rollback => e
      render json: { errors: e.message }, status: :unprocessable_entity
    rescue => e
      render json: { errors: "Erro ao criar funcionário: #{e.message}" }, 
            status: :unprocessable_entity
    end
  end

  def update
    ActiveRecord::Base.transaction do
      unless @funcionario.update(funcionario_params.except(:criar_usuario, :email, :password))
        raise ActiveRecord::Rollback, @funcionario.errors.full_messages.to_sentence
      end

      if should_create_or_update_user?
        if @funcionario.usuario
          update_existing_user(@funcionario)
        else
          create_user_for_funcionario(@funcionario)
        end
      end

      render json: @funcionario, include: [:usuario], status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    rescue => e
      render json: { errors: "Erro ao atualizar funcionário: #{e.message}" }, status: :unprocessable_entity
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      # Deactivate associated user if exists
      if @funcionario.usuario
        ActiveRecord::Base.establish_connection(Rails.env.to_sym)
        usuario_principal = Usuario.find_by(token_identificacao: @funcionario.usuario_token_identificacao)
        usuario_principal&.update!(ativo: false)
        
        @funcionario.usuario.update!(ativo: false)
      end
      
      @funcionario.update!(status: 'desativado', data_desativacao: Date.current)
      head :no_content
    end
  end

  private

  def create_in_tenant_db
    # Switch to tenant DB
    tenant_config = current_tenant_db_config
    ActiveRecord::Base.establish_connection(tenant_config)

    funcionario = Funcionario.new(
      funcionario_params.except(:criar_usuario, :email, :password)
    )
    funcionario.attributes = {
      informacao_loja_token: current_tenant.token_integracao,
      ativo: true,
      data_admissao: Date.current
    }

    if funcionario.save
      # Verificação explícita de persistência
      unless Funcionario.exists?(funcionario.id)
        return { success: false, error: "Funcionário não persistido no banco tenant" }
      end
      
      { success: true, funcionario: funcionario }
    else
      { success: false, error: funcionario.errors.full_messages.to_sentence }
    end
  ensure
    ActiveRecord::Base.establish_connection(Rails.env.to_sym)
  end
  
  def set_funcionario
    @funcionario = Funcionario.find_by(
      id: params[:id], 
      informacao_loja_token: @current_user.token_integracao_loja
    )
    render json: { error: 'Funcionário não encontrado' }, status: :not_found unless @funcionario
  end

  def funcionario_params
    params.require(:funcionario).permit(
      :nome, :cpf, :rg, :data_nascimento, :cargo, :salario_base,
      :comissao_percentual, :data_admissao, :endereco, :telefone,
      :email, :observacoes, :criar_usuario, :password
    )
  end

  def should_create_or_update_user?
    params[:funcionario][:criar_usuario].to_s.downcase == 'true' ||
    (params[:funcionario][:email].present? && @funcionario.usuario)
  end

  def create_user_for_funcionario(funcionario)
    email = params[:funcionario][:email] || funcionario.email
    password = params[:funcionario][:password] || SecureRandom.hex(8)
    token_identificacao = SecureRandom.uuid # Gerando UUID no formato correto

    # 1. Primeiro cria o usuário no banco principal
    ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    main_user = Usuario.create!(
      nome: funcionario.nome,
      email: email,
      password: password,
      password_confirmation: password,
      role: 'funcionario',
      tipo_acesso: 'funcionario',
      ativo: true,
      token_integracao_loja: current_tenant.token_integracao,
      token_identificacao: token_identificacao, # Esta é a coluna correta
      id_funcionario: funcionario.id
    )

    # 2. Depois cria no tenant database
    ActiveRecord::Base.establish_connection(current_tenant_db_config)
    tenant_user = Usuario.create!(
      nome: funcionario.nome,
      email: email,
      password: password,
      password_confirmation: password,
      role: 'funcionario',
      tipo_acesso: 'funcionario',
      ativo: true,
      token_integracao_loja: current_tenant.token_integracao,
      token_identificacao: token_identificacao, # Mesmo valor aqui
      id_funcionario: funcionario.id
    )

    # 3. ATUALIZAÇÃO CORRETA - usa usuario_token_identificacao que referencia token_identificacao
    funcionario.update!(
      usuario_token_identificacao: token_identificacao, # Coluna que existe em funcionarios
      email: email
    )
  rescue => e
    # Rollback em caso de erro
    main_user&.destroy
    tenant_user&.destroy
    raise ActiveRecord::Rollback, "Falha ao criar usuário: #{e.message}"
  ensure
    ActiveRecord::Base.establish_connection(Rails.env.to_sym)
  end

  def current_tenant_db_config
    config_file = Rails.root.join('config', 'databases', "#{current_tenant.token_integracao}.yml")
    if File.exist?(config_file)
      YAML.load_file(config_file)
    else
      Rails.logger.error "Tenant config file not found: #{config_file}"
      raise "Tenant database configuration not found"
    end
  end

  def update_existing_user(funcionario)
    email = params[:funcionario][:email] || funcionario.email
    password = params[:funcionario][:password]

    # Update in main database
    ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    usuario_principal = Usuario.find_by(token_identificacao: funcionario.usuario_token_identificacao)
    update_params = { nome: funcionario.nome, email: email }
    update_params[:password] = password if password.present?
    update_params[:password_confirmation] = password if password.present?
    
    usuario_principal.update!(update_params)

    # Update in tenant database
    funcionario.usuario.update!(update_params)

    # Update funcionario email if changed
    funcionario.update!(email: email) if funcionario.email != email
  end

  def current_tenant
    @current_tenant ||= InformacaoLoja.find_by(token_integracao: @current_user.token_integracao_loja)
  end
end