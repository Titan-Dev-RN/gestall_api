class Api::V1::ServicosController < ApplicationController
  before_action :set_servico, only: %i[ show update destroy ativar]

  # GET /servicos
  def index
    @servicos = Servico.all

    render json: @servicos
  end

  # GET /servicos/1
  def show
    render json: @servico
  end

  # POST /servicos
  def create
    @servico = Servico.new(servico_params)
    @servico.token_integracao_loja = @current_user.token_integracao_loja
    
    if @servico.save
      render json: @servico, status: :created
    else
      render json: @servico.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /servicos/1
  def update
    if @servico.update(servico_params)
      render json: @servico
    else
      render json: @servico.errors, status: :unprocessable_entity
    end
  end

  # DELETE /servicos/1
  def destroy
    @servico.update(status: false)

    render json: { message: 'Serviço desativado com sucesso.' }, status: :ok
  end

  def ativar
    @servico.update(status: true)

    render json: { message: 'Serviço ativado com sucesso.' }, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_servico
      if @servico = Servico.find(params[:id])
      else
        render json: { error: 'Serviço não encontrado.' }, status: :not_found
      end
    end

    # Only allow a list of trusted parameters through.
    def servico_params
      params.require(:servico).permit(:nome, :descricao, :valor, :categoria_id, :token_integracao_loja, :usuario_token_identificacao, :status)
    end
end
