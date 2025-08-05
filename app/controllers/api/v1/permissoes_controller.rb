class Api::V1::PermissoesController < ApplicationController
    before_action :verificar_admin

    def index
        permissoes = Permissao.where(token_integracao_loja: current_user.token_integracao_loja)
        render json: permissoes
    end

    def atribuir
        usuario = Usuario.find_by(token_identificacao: params[:usuario_token])
        permissao = Permissao.find_by(token: params[:permissao_token])

        if usuario.token_integracao_loja != current_user.token_integracao_loja
            render json: { error: 'Acesso negado' }, status: :forbidden
            return
        end

        UsuarioPermissao.create(
            usuario_token_identificacao: usuario.token_identificacao,
            permissao_token: permissao.token,
            token_integracao_loja: usuario.token_integracao_loja
        )

        render json: { message: 'Permissão atribuída com sucesso' }
    end

    def remover
        usuario = Usuario.find(params[:usuario_id])
        permissao = Permissao.find(params[:permissao_id])

        if usuario.token_integracao_loja != current_user.token_integracao_loja
            render json: { error: 'Acesso negado' }, status: :forbidden
            return
        end

        usuario.permissoes.delete(permissao)
        render json: { message: 'Permissão removida com sucesso' }
        end

        private

        def verificar_admin
        unless current_user.admin_loja? || current_user.super_admin?
            render json: { error: 'Acesso negado' }, status: :forbidden
        end
    end
end