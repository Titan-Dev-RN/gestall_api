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

      # Agora cria no banco do tenant
      ActiveRecord::Base.establish_connection(
        adapter: "postgresql",
        database: "gestall_#{current_tenant.token_integracao.parameterize.underscore}",
        **InformacaoLoja::FIXED_DB_CONFIG.except(:dbname)
      )
      @funcionario = Funcionario.new(funcionario_params.except(:criar_usuario))
      @funcionario.informacao_loja_token = current_tenant.token_integracao
      @funcionario.ativo = true
      @funcionario.data_admissao ||= Date.current
      
      unless @funcionario.save
        raise ActiveRecord::Rollback, @funcionario.errors.full_messages.to_sentence
      end

      if params[:funcionario][:criar_usuario].to_s.downcase == 'true'
        # Cria usuário no banco principal
        ActiveRecord::Base.establish_connection(Rails.env.to_sym)
        token_identificacao = SecureRandom.hex(16)
        usuario_principal = Usuario.create!(
          nome: @funcionario.nome,
          email: params[:funcionario][:email],
          password: params[:funcionario][:password],
          password_confirmation:  params[:funcionario][:password],
          role: 'funcionario',
          tipo_acesso: 'funcionario',
          ativo: true,
          token_integracao_loja: current_tenant.token_integracao,
          token_identificacao: token_identificacao,
          id_funcionario: @funcionario.id
        )

        # Cria usuário no banco tenant
        ActiveRecord::Base.establish_connection(
          adapter: "postgresql",
          database: "gestall_#{current_tenant.token_integracao.parameterize.underscore}",
          **InformacaoLoja::FIXED_DB_CONFIG.except(:dbname)
        )
        usuario_tenant = Usuario.create!(
          nome: @funcionario.nome,
          email: params[:funcionario][:email],
          password: params[:funcionario][:password],
          password_confirmation:  params[:funcionario][:password],
          role: 'funcionario',
          tipo_acesso: 'funcionario',
          ativo: true,
          token_integracao_loja: current_tenant.token_integracao,
          token_identificacao: token_identificacao,
          id_funcionario: @funcionario.id
        )

        @funcionario.update(usuario_token_identificacao: usuario_tenant.token_identificacao)
      end

      render json: @funcionario, include: [:usuario], status: :created
    rescue ActiveRecord::Rollback => e
      render json: { errors: e.message }, status: :unprocessable_entity
    rescue => e
      render json: { errors: "Erro ao criar funcionário: #{e.message}" }, status: :unprocessable_entity
    ensure
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    end
  end

  def update
    ActiveRecord::Base.transaction do
      # 1. Atualiza no banco principal
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      funcionario_principal = Funcionario.find_by(
        id: @funcionario.id, 
        informacao_loja_token: current_tenant.token_integracao
      )
      
      unless funcionario_principal
        raise ActiveRecord::Rollback, 'Funcionário não encontrado no banco principal'
      end

      unless funcionario_principal.update(funcionario_params.except(:criar_usuario))
        raise ActiveRecord::Rollback, funcionario_principal.errors.full_messages.to_sentence
      end

      # 2. Atualiza no banco tenant
      ActiveRecord::Base.establish_connection(
        adapter: "postgresql",
        database: "gestall_#{current_tenant.token_integracao.parameterize.underscore}",
        **InformacaoLoja::FIXED_DB_CONFIG.except(:dbname)
      )
      
      unless @funcionario.update(funcionario_params.except(:criar_usuario))
        raise ActiveRecord::Rollback, @funcionario.errors.full_messages.to_sentence
      end

      # 3. Lógica para atualização/criação de usuário
      if params[:funcionario][:criar_usuario].to_s.downcase == 'true' && !@funcionario.usuario
        # Cria usuário em ambos os bancos
        ActiveRecord::Base.establish_connection(Rails.env.to_sym)
        usuario_principal = Usuario.create!(
          nome: funcionario_principal.nome,
          email: params[:funcionario][:email] || funcionario_principal.email,
          role: 'funcionario',
          tipo_acesso: 'funcionario',
          ativo: true,
          token_integracao_loja: current_tenant.token_integracao,
          id_funcionario: funcionario_principal.id
        )

        ActiveRecord::Base.establish_connection(
          adapter: "postgresql",
          database: "gestall_#{current_tenant.token_integracao.parameterize.underscore}",
          **InformacaoLoja::FIXED_DB_CONFIG.except(:dbname)
        )
        usuario_tenant = Usuario.create!(
          nome: @funcionario.nome,
          email: params[:funcionario][:email] || @funcionario.email,
          role: 'funcionario',
          tipo_acesso: 'funcionario',
          ativo: true,
          token_integracao_loja: current_tenant.token_integracao,
          id_funcionario: @funcionario.id
        )

        # Atualiza referências
        funcionario_principal.update!(usuario_id: usuario_principal.id)
        @funcionario.update!(usuario_id: usuario_tenant.id)
      elsif @funcionario.usuario
        # Atualiza usuário existente em ambos os bancos
        ActiveRecord::Base.establish_connection(Rails.env.to_sym)
        if usuario_principal = Usuario.find_by(id_funcionario: funcionario_principal.id)
          usuario_principal.update!(
            nome: funcionario_principal.nome,
            email: params[:funcionario][:email] || funcionario_principal.email,
            ativo: true
          )
        end

        ActiveRecord::Base.establish_connection(
          adapter: "postgresql",
          database: "gestall_#{current_tenant.token_integracao.parameterize.underscore}",
          **InformacaoLoja::FIXED_DB_CONFIG.except(:dbname)
        )
        @funcionario.usuario.update!(
          nome: @funcionario.nome,
          email: params[:funcionario][:email] || @funcionario.email,
          ativo: true
        )
      end

      render json: @funcionario, include: [:usuario], status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    rescue => e
      render json: { errors: "Erro ao atualizar funcionário: #{e.message}" }, status: :unprocessable_entity
    ensure
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      @funcionario.usuario&.update(ativo: false) # Desativa usuário se existir
      @funcionario.update(ativo: false, data_demissao: Date.current)
      head :no_content
    end
  end

  private

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
      :email, :observacoes, :criar_usuario
    )
  end

  def usuario_params
    params.require(:usuario).permit(
      :nome, 
      :email, 
      :password, 
      :password_confirmation, 
      :role, 
      :password_reset_required, 
      :tipo_acesso, 
      :ativo, 
      :token_integracao_loja, 
      :id_funcionario
    )
  end

  def criar_usuario_para_funcionario(funcionario)
    # Define valores padrão para o usuário
    usuario_attrs = {
      nome: funcionario.nome,
      email: params[:usuario][:email] || funcionario.email,
      password: params[:usuario][:password] || SecureRandom.hex(8),
      password_confirmation: params[:usuario][:password_confirmation] || params[:usuario][:password] || SecureRandom.hex(8),
      role: params[:usuario][:role] || 'funcionario',
      tipo_acesso: params[:usuario][:tipo_acesso] || 'funcionario',
      ativo: true,
      token_integracao_loja: current_tenant.token_integracao,
      id_funcionario: funcionario.id
    }

    Usuario.create!(usuario_attrs)
  end

  def current_tenant
    @current_tenant ||= InformacaoLoja.find_by(token_integracao: @current_user.token_integracao_loja)
  end
end