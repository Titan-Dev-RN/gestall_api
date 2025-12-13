class Api::V1::MovimentacoesController < ApplicationController

    def index
        movimentacoes = HistoricoEstoque.where(informacao_loja_token: @current_user.token_integracao_loja)
        render json: movimentacoes
    end
end
