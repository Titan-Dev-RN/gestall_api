class Usuarios::SessionsController < Devise::SessionsController
    respond_to :json
  
    private
  
    def respond_with(resource, _opts = {})
      render json: {
        message: 'Login realizado com sucesso!',
        usuario: current_usuario,
        token: request.env['warden-jwt_auth.token']
      }, status: :ok
    end
  
    def respond_to_on_destroy
      jwt_payload = JWT.decode(
        request.headers['Authorization'].split(' ').last,
        Rails.application.credentials.jwt_secret_key,
        true,
        algorithm: 'HS256'
      )
      current_usuario = Usuario.find(jwt_payload[0]['sub'])
  
      if current_usuario
        render json: { message: "Logout realizado com sucesso!" }, status: :ok
      else
        render json: { message: "Falha ao realizar logout" }, status: :unauthorized
      end
    rescue
      render json: { message: "Token inválido" }, status: :unauthorized
    end
  end
  