class Usuarios::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token
  respond_to :json
  def create
    user = Usuario.find_for_database_authentication(email: params[:usuario][:email])
    
    if user&.valid_password?(params[:usuario][:password])

      token = generate_jwt_token(user)
       
      render json: {
        status: 'success',
        usuario: {
          id: user.id,
          email: user.email,
          tipo_acesso: user.tipo_acesso,
          loja_ativa: loja_ativa?(user)
        },
        token: token
      }, status: :ok
    else
      render json: { error: 'Email ou senha inválidos' }, status: :unauthorized
    end
  end

  private
  def loja_ativa?(user)
    loja = InformacaoLoja.find_by(id: user.id_loja)
    loja&.ativo
  end

  def generate_jwt_token(user)
    payload = {
      sub: user.id,
      exp: 24.hours.from_now.to_i,
      jti: SecureRandom.uuid,
      user_data: {
        email: user.email,
        tipo_acesso: user.tipo_acesso
      }
    }
    
    # Verificação extrema da chave
    raise "Chave JWT_SECRET_KEY ausente!" unless ENV['JWT_SECRET_KEY'].present?
    
    JWT.encode(payload, ENV['JWT_SECRET_KEY'], 'HS256')
  rescue => e
    Rails.logger.error "ERRO NA GERAÇÃO DO TOKEN: #{e.message}"
    raise
  end
end