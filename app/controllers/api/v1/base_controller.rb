class Api::V1::BaseController < ApplicationController
    before_action :authenticate_user!
    
    private
  
    def authorize_loja
      unless current_user.admin_loja?
        render json: { error: 'Acesso não autorizado' }, status: :forbidden
      end
    end
  
    def authorize_vendedor
      unless current_user.funcionario?
        render json: { error: 'Acesso não autorizado' }, status: :forbidden
      end
    end
  
    def current_loja
      @current_loja ||= current_user.informacao_loja
    end
  end