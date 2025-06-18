class ApplicationController < ActionController::API
  include ActionController::RequestForgeryProtection
  protect_from_forgery with: :null_session 
  
  before_action :set_default_format
  before_action :authenticate_api_request, unless: -> { auth_whitelist? }
  before_action :verificar_loja_ativa, unless: -> { auth_whitelist? }

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_record
  rescue_from JWT::DecodeError, with: :invalid_token

  def current_tenant
    @current_tenant ||= InformacaoLoja.find_by(token_integracao: @current_user.token_integracao_loja) if @current_user
  end

  private
  def verificar_loja_ativa
    return unless @current_user
    return if @current_user.super_admin?

    loja = InformacaoLoja.find_by(token_integracao: @current_user.token_integracao_loja)
    unless loja
      render json: { error: 'Loja não encontrada.' }, status: :not_found and return
    end
    unless loja.ativo
      render json: { error: 'Loja inativa ou vencida. Regularize o pagamento.' }, status: :payment_required
    end
  end

  def set_default_format
    request.format = :json
  end

  def authenticate_api_request
    auth_header = request.headers['Authorization']
    
    unless auth_header.present?
      render json: { error: 'Cabeçalho de autorização ausente' }, status: :unauthorized
      return
    end

    unless auth_header.start_with?('Bearer ')
      render json: { error: 'Formato deve ser: Bearer <token>' }, status: :unauthorized
      return
    end

    token = auth_header.split(' ').last
    
    begin
      secret = ENV['JWT_SECRET_KEY']
      raise "Chave JWT_SECRET_KEY ausente!" unless secret.present?
      
      decoded = JWT.decode(
        token, 
        secret,
        true,
        { algorithm: 'HS256', verify_expiration: true }
      )
      
      @current_user = Usuario.find(decoded.first['sub'])

    rescue JWT::ExpiredSignature
      render json: { error: 'Token expirado' }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { 
        error: 'Token inválido',
        details: e.message,
        solution: 'Verifique se o token está completo e foi gerado com a mesma chave secreta'
      }, status: :unauthorized
    rescue => e
      render json: { error: 'Erro de autenticação', details: e.message }, status: :internal_server_error
    end
  end
  
  def auth_whitelist?
    controller_name == 'sessions' && action_name == 'create'
  end
end