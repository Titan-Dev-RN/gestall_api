class Api::V1::FornecedoresController < ApplicationController
  before_action :set_fornecedor, only: [:show, :update, :destroy, :reativar_fornecedor]

  
  def index
    fornecedores = Fornecedor.where(informacao_loja_token: @current_user.token_integracao_loja)
    render json: fornecedores
  end
  
  # GET /api/v1/fornecedores/:id
  def show
    render json: @fornecedor
  end

  # POST /api/v1/fornecedores
  def create
    fornecedor = Fornecedor.new(fornecedor_params)
    fornecedor.informacao_loja = @current_user.informacao_loja

    if fornecedor.save
      render json: fornecedor, status: :created
    else
      render json: fornecedor.errors, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/fornecedores/:id
  def update
    if @fornecedor.update(fornecedor_params)
      render json: @fornecedor
    else
      render json: @fornecedor.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/fornecedores/:id
  def destroy
    @fornecedor.update(ativo: false)
    render json: { message: 'Fornecedor desativado com sucesso'}, status: :ok
  end

  def reativar_fornecedor
      @fornecedor.update(ativo: true)
      render json: { message: 'Fornecedor reativado com sucesso'}, status: :ok
  end
  
  private

  def set_fornecedor
    @fornecedor = Fornecedor.find_by(
      id: params[:id],
      informacao_loja_token: @current_user.token_integracao_loja
    )
    render json: { error: 'Fornecedor não encontrado' }, status: :not_found unless @fornecedor
  end
  
  def fornecedor_params
    params.require(:fornecedor).permit(
      :nome,
      :cnpj,
      :contato,
      :telefone,
      :email,
      :endereco,
      :observacoes,
      :ativo
    )
  end
end
  