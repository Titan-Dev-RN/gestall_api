class Api::V1::FuncionariosController < ApplicationController
  before_action :authorize_admin_loja!
  before_action :set_funcionario, only: [:show, :update, :destroy]

  def index
    funcionarios = Usuario.where(
      token_integracao_loja: @current_user.token_integracao_loja, 
      tipo_acesso: :funcionario
    )
    render json: funcionarios
  end

  # GET /api/v1/funcionarios/:id
  def show
    render json: @funcionario
  end

  # POST /api/v1/funcionarios
  def create
    funcionario = Usuario.new(funcionario_params.merge(
      id_loja: @current_user.id_loja,
      tipo_acesso: :funcionario,
      ativo: true
    ))
    if funcionario.save
      render json: funcionario, status: :created
    else
      render json: { errors: funcionario.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/funcionarios/:id
  def update
    if @funcionario.update(funcionario_params)
      render json: @funcionario
    else
      render json: { errors: @funcionario.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/funcionarios/:id
  def destroy
    @funcionario.destroy
    head :no_content
  end

  private
  def authorize_admin_loja!
    unless @current_user&.admin_loja?
      render json: { error: 'Acesso não autorizado' }, status: :forbidden
    end
  end

  def set_funcionario
    @funcionario = Usuario.find_by(
      id: params[:id], 
      token_integracao_loja: @current_user.token_integracao_loja,
      tipo_acesso: :funcionario
    )
    unless @funcionario
      render json: { error: 'Funcionário não encontrado' }, status: :not_found
    end
  end

  def funcionario_params
    params.require(:usuario).permit(:nome, :email, :password, :password_confirmation, :ativo)
  end
end