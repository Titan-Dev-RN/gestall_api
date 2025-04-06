class UsuariosController < ApplicationController
    def create
      @usuario = Usuario.new(usuario_params)
      if @usuario.save
        render json: { message: "Usuário criado com sucesso", usuario: @usuario }, status: :created
      else
        render json: { errors: @usuario.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    private
  
    def usuario_params
      params.require(:usuario).permit(:nome, :email, :password, :password_confirmation, :role, :password_reset_required)
    end
  end
  