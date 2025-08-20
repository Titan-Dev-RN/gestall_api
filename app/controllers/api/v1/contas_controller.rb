class Api::V1::ContasController < ApplicationController
  before_action :set_conta, only: %i[ show update destroy ]

  def index
    @contas = Contas.all

    render json: @contas
  end

  def show
    render json: @conta
  end

  def create
    @conta = Contas.new(conta_params)
    if @conta.save
      @conta.token_integracao_loja = @current_user.token_integracao_loja
      @conta.save!
      render json: @conta, status: :created
    else
      render json: @conta.errors, status: :unprocessable_entity
    end
  end

  def update
    if @conta.update(conta_params)
      render json: @conta
    else
      render json: @conta.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @conta.destroy!
    render json: { message: 'Conta deletada com sucesso.' }
  end

  private
    def set_conta
      @conta = Contas.find(params.require(:id))
    end

    def conta_params
      params.require(:conta).permit(
        :descricao,
        :destinatario,
        :tipo,
        :valor,
        :categorias_id,
        :vencimento,
        :status,
        :observacao
      )
    end
end
