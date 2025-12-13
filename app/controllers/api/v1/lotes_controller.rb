class Api::V1::LotesController < ApplicationController
    before_action :set_lote, only: [:show, :update, :destroy]

    def index
        lotes = Lote.where(informacao_loja_token: @current_user.token_integracao_loja)
        render json: lotes
    end

    def show
        render json: @lote
    end

    def create
        lote = Lote.new(lote_params)
        lote.informacao_loja_token = @current_user.token_integracao_loja

        if lote.save
            render json: lote, status: :created
        else
            render json: { errors: lote.errors.full_messages }, status: :unprocessable_entity
        end
    end
    
    def update
        if @lote.update(lote_params)
            render json: @lote
        else
            render json: { errors: @lote.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def destroy
        if @lote.destroy
            render json: { message: 'Lote deleted successfully' }
        end
    end

    private

    def set_lote
        @lote = Lote.find_by(id: params[:id], informacao_loja_token: @current_user.token_integracao_loja)
        if @lote.nil?
            render json: { error: 'Lote não encontrado' }, status: :not_found
        end
    end

    def lote_params
        params.require(:lote).permit(:codigo, :data_validade, :quantidade, :produto_id)
    end

end
