class Api::V1::FuncionariosController < ApplicationController
  before_action :set_funcionario, only: [:show, :update, :destroy]

  # GET /api/v1/funcionarios
  def index
    funcionarios = Funcionario.where(
      informacao_loja_token: @current_user.token_integracao_loja
    ).includes(:usuario)
    
    render json: funcionarios, include: [:usuario]
  end

  # GET /api/v1/funcionarios/:id
  def show
    render json: @funcionario, include: [:usuario]
  end

  # POST /api/v1/funcionarios
  def create
    ActiveRecord::Base.transaction do
      # Cria primeiro o funcionário base
      @funcionario = Funcionario.new(funcionario_params.except(:criar_usuario))
      @funcionario.informacao_loja_token = current_tenant.id
      @funcionario.ativo = true
      @funcionario.data_admissao ||= Date.current

      unless @funcionario.save
        raise ActiveRecord::Rollback, @funcionario.errors.full_messages.to_sentence
      end

      # Verifica se deve criar usuário
      if params[:funcionario][:criar_usuario].to_s.downcase == 'true'
        usuario_attrs = {
          nome: @funcionario.nome,
          email: params[:funcionario][:email], # Usa o mesmo email do funcionário
          password: "senha123",
          password_confirmation: "senha123",
          role: 'funcionario',
          tipo_acesso: 'funcionario',
          ativo: true,
          token_integracao_loja: current_tenant.token_integracao,
          id_funcionario: @funcionario.id
        }

        usuario = Usuario.create(usuario_attrs)
        
        unless usuario.persisted?
          raise ActiveRecord::Rollback, usuario.errors.full_messages.to_sentence
        end

        @funcionario.update(usuario_id: usuario.id)
      end

      render json: @funcionario, include: [:usuario], status: :created
    rescue ActiveRecord::Rollback => e
      render json: { errors: e.message }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/funcionarios/:id
  def update
    ActiveRecord::Base.transaction do
      if @funcionario.update(funcionario_params.except(:criar_usuario))
        # Atualiza ou cria usuário se necessário
        if params[:usuario] && params[:usuario][:criar_usuario] && !@funcionario.usuario
          usuario = criar_usuario_para_funcionario(@funcionario)
          unless usuario.persisted?
            raise ActiveRecord::Rollback, usuario.errors.full_messages.to_sentence
          end
          @funcionario.update(usuario_id: usuario.id)
        end

        render json: @funcionario, include: [:usuario]
      else
        render json: { errors: @funcionario.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  # DELETE /api/v1/funcionarios/:id
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
      :email, :password, :password_confirmation, :role, :tipo_acesso
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