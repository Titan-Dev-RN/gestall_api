class ApplicationController < ActionController::API
  include ActionController::RequestForgeryProtection
  protect_from_forgery with: :null_session 
  
  before_action :set_default_format
  before_action :authenticate_api_request, unless: -> { auth_whitelist? }
  
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_record
  rescue_from JWT::DecodeError, with: :invalid_token

  private

  def set_default_format
    request.format = :json
  end

  def authenticate_api_request
    auth_header = request.headers['Authorization']
    
    # Debug inicial
    Rails.logger.info "🔍 HEADER Authorization recebido: #{auth_header.inspect}"
    
    unless auth_header.present?
      render json: { error: 'Cabeçalho de autorização ausente' }, status: :unauthorized
      return
    end

    unless auth_header.start_with?('Bearer ')
      render json: { error: 'Formato deve ser: Bearer <token>' }, status: :unauthorized
      return
    end

    token = auth_header.split(' ').last
    
    # Debug detalhado
    Rails.logger.info "🔐 TOKEN RECEBIDO: #{token}"
    Rails.logger.info "📏 TAMANHO: #{token.size} caracteres"
    Rails.logger.info "🧩 SEGMENTOS: #{token.split('.').size}"

    begin
      # Verificação extrema da chave
      secret = ENV['JWT_SECRET_KEY']
      raise "Chave JWT_SECRET_KEY ausente!" unless secret.present?
      
      decoded = JWT.decode(
        token, 
        secret,
        true,
        { algorithm: 'HS256', verify_expiration: true }
      )
      
      Rails.logger.info "✅ TOKEN DECODIFICADO: #{decoded.inspect}"
      @current_user = Usuario.find(decoded.first['sub'])

    rescue JWT::ExpiredSignature
      render json: { error: 'Token expirado' }, status: :unauthorized
    rescue JWT::DecodeError => e
      Rails.logger.error "❌ FALHA NA DECODIFICAÇÃO: #{e.message}"
      Rails.logger.error "🛑 TOKEN COMPLETO: #{token}"
      
      render json: { 
        error: 'Token inválido',
        details: e.message,
        solution: 'Verifique se o token está completo e foi gerado com a mesma chave secreta'
      }, status: :unauthorized
    rescue => e
      Rails.logger.error "‼️ ERRO INESPERADO: #{e.message}"
      render json: { error: 'Erro de autenticação' }, status: :internal_server_error
    end
  end
  
  def auth_whitelist?
    controller_name == 'sessions' && action_name == 'create'
  end
  # ... outros métodos ...
end