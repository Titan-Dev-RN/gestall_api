class Api::V1::AdminSuper::UsuariosController < ApplicationController
  before_action :authorize_super_admin

  def show
    @usuario = Usuario.find_by(id: params[:id])

    unless @usuario
      render json: { error: "Usuário não encontrado" }, status: :not_found and return
    end

    render json: @usuario, status: :ok
  end

  private

  def authorize_super_admin
    unless @current_user&.super_admin?
      render json: { error: "Acesso negado." }, status: :forbidden and return
    end
  end
end