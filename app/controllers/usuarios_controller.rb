class UsuariosController < ApplicationController
  def index
    @usuarios = Usuario.all
    render json: @usuarios, status: :ok
  end
  
  # def usuario_by_email
  #   email = params[:email]
  #   puts "Email recebido: #{email}"
    
  #   @usuario = Usuario.find_by(email: email)
    
  #   unless @usuario
  #     puts "Tentando busca parcial..."
  #     @usuario = Usuario.where("email ILIKE ?", "%#{email}%").first
  #   end
    
  #   if @usuario
  #     render json: @usuario, status: :ok
  #   else
  #     puts "Usuário não encontrado para email: #{email}"
  #     puts "Usuários existentes: #{Usuario.pluck(:email)}"
  #     render json: { error: "Usuário não encontrado" }, status: :not_found
  #   end
  # end

  def usuario_by_email
    # suporta: { "email": "user@example.com" } ou { "usuario": { "email": "user@example.com" } }
    email = params[:email].presence || params.dig(:usuario, :email).presence

    unless email
      Rails.logger.warn "Requisição sem email no body"
      render json: { error: "Parâmetro 'email' ausente no body" }, status: :bad_request and return
    end

    Rails.logger.info "Email recebido: #{email}"

    @usuario = Usuario.find_by(email: email)

    unless @usuario
      Rails.logger.info "Tentando busca parcial por email..."
      @usuario = Usuario.where("email ILIKE ?", "%#{email}%").first
    end

    if @usuario
      render json: @usuario, status: :ok
    else
      Rails.logger.info "Usuário não encontrado para email: #{email}"
      Rails.logger.debug "Usuários existentes: #{Usuario.pluck(:email)}"
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