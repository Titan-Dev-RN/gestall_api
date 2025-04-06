class ApplicationController < ActionController::API
    include ActionController::MimeResponds
  
    before_action :set_default_format
    before_action :verificar_plano_ativo


    def verificar_plano_ativo
      return unless current_usuario&.loja
      unless current_usuario.loja.ativo?
        render json: { error: 'Acesso bloqueado por falta de pagamento.' }, status: :unauthorized
      end
    end
    
    private
  
    def set_default_format
      request.format = :json
    end
end
  