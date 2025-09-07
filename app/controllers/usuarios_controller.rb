class UsuariosController < ApplicationController
  def index
    @usuarios = Usuario.all
    render json: @usuarios, status: :ok
  end
  
  def usuario_by_email
    email = params[:email]
    puts "Email recebido: #{email}"
    
    @usuario = Usuario.find_by(email: email)
    
    unless @usuario
      puts "Tentando busca parcial..."
      @usuario = Usuario.where("email ILIKE ?", "%#{email}%").first
    end
    
    if @usuario
      render json: @usuario, status: :ok
    else
      puts "Usuário não encontrado para email: #{email}"
      puts "Usuários existentes: #{Usuario.pluck(:email)}"
      render json: { error: "Usuário não encontrado" }, status: :not_found
    end
  end

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
end