class Api::V1::AdminSuper::InformacoesLojasController < ApplicationController
  before_action :authorize_super_admin

  def update
    @informacao_loja = InformacaoLoja.find_by(id: params[:id])

    unless @informacao_loja
      render json: { error: "Loja não encontrada" }, status: :not_found and return
    end

    if @informacao_loja.update(informacao_loja_params)
      render json: @informacao_loja, status: :ok
    else
      render json: { errors: @informacao_loja.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def authorize_super_admin
    unless @current_user&.super_admin?
      render json: { error: "Acesso negado." }, status: :forbidden and return
    end
  end

  def informacao_loja_params
    params.require(:informacao_loja).permit(:nome_da_loja, :telefone, :email, :token_integracao)
  end
end