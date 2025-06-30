class Api::V1::ClientesController < ApplicationController
  before_action :set_cliente, only: [:show, :update, :destroy, :reativar_cliente]

  def index
    clientes = Cliente.where(informacao_loja_id: @current_user.informacao_loja.id)
    render json: clientes
  end

  # GET /api/v1/clientes/:id
  def show
    render json: @cliente
  end

  # POST /api/v1/clientes
  def create
      
  cliente = Cliente.new(cliente_params.merge(informacao_loja: @current_user.informacao_loja))
  cliente.data_cadastro = Time.current

    if cliente.save
      render json: cliente, status: :created
    else
      render json: cliente.errors, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/clientes/:id
  def update
    if @cliente.update(cliente_params)
      render json: @cliente
    else
      render json: @cliente.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/clientes/:id
  def destroy
    @cliente.update(ativo: false)
    render json: { message: 'cliente desativado com sucesso'}, status: :ok
  end

  def reativar_cliente
      @cliente.update(ativo: true)
      render json: { message: 'Cliente reativado com sucesso'}, status: :ok
  end

  private

  def set_cliente
    @cliente = Cliente.find_by(
      id: params[:id], 
      informacao_loja_id: InformacaoLoja.find_by(token_integracao: @current_user.token_integracao_loja)&.id
    )
    render json: { error: 'Cliente não encontrado' }, status: :not_found unless @cliente
  end

  def cliente_params
    params.require(:cliente).permit(
      :nome, :cpf_cnpj, :telefone, :email, :endereco, :ativo
    )
  end
end