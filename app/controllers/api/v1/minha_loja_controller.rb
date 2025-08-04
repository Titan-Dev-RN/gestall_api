class Api::V1::MinhaLojaController < ApplicationController
    before_action :set_loja, only: [:show, :update]

    def show
      if @loja
        render json: @loja, status: :ok
      else
        render json: { error: 'Loja não encontrada' }, status: :not_found
      end
    end

    def update
        if @current_user.tipo_acesso == "admin_loja"
          if @loja.update(loja_params)
            render json: @loja, status: :ok
          else
            render json: { error: 'Falha ao atualizar loja' }, status: :unprocessable_entity
          end
        else
          render json: { error: 'Acesso negado' }, status: :forbidden
        end
    end

    private 

    def set_loja
      @loja = InformacaoLoja.find_by(token_integracao: @current_user.token_integracao_loja) if @current_user
      return if @loja
      render json: { error: 'Loja não encontrada' }, status: :not_found
    end

    def loja_params
        params.require(:informacao_loja).permit(
        :nome_da_loja, :nome_dono, :forma_de_pagamento, :endereco,
        :cidade, :estado, :cnpj, :telefone, :email, :plano_contratado,
        :data_vencimento_plano
        )
    end  
end
