class Usuarios::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token
  respond_to :json
  
  def create
    user = Usuario.find_for_database_authentication(email: params[:usuario][:email])
    
    if user&.valid_password?(params[:usuario][:password])
      token = generate_jwt_token(user)
      loja = InformacaoLoja.find_by(token_integracao: user.token_integracao_loja)
      
      response_data = {
        status: 'success',
        usuario: {
          id: user.token_identificacao,
          email: user.email,
          tipo_acesso: user.tipo_acesso,
          loja_ativa: loja&.ativo
        },
        token: token
      }

      if loja
        response_data[:loja] = {
          nome: loja.nome_da_loja,
          token_integracao: loja.token_integracao,
          ativo: loja.ativo,
          cnpj: loja.cnpj,
          cidade: loja.cidade,
          estado: loja.estado,
          endereco: loja.endereco,
          telefone: loja.telefone,
          email: loja.email,
          plano: loja.plano_contratado,
        }
      end

      render json: response_data, status: :ok
    else
      render json: { error: 'Email ou senha inválidos' }, status: :unauthorized
    end
  end

  private

  def generate_jwt_token(user)
    payload = {
      sub: user.token_identificacao,
      exp: 24.hours.from_now.to_i,
      jti: SecureRandom.uuid,
      user_data: {
        email: user.email,
        tipo_acesso: user.tipo_acesso,
        token_integracao_loja: user.token_integracao_loja
      }
    }
    
    raise "Chave JWT_SECRET_KEY ausente!" unless ENV['JWT_SECRET_KEY'].present?
    
    JWT.encode(payload, ENV['JWT_SECRET_KEY'], 'HS256')
  rescue => e
    Rails.logger.error "ERRO NA GERAÇÃO DO TOKEN: #{e.message}"
    raise
  end
end