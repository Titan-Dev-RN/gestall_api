class Api::V1::PermissoesController < ApplicationController
    before_action :verificar_admin

    def index
        permissoes = Permissao.where(token_integracao_loja: current_user.token_integracao_loja)
        render json: permissoes
    end

    def atribuir
        usuario = Usuario.find_by(token_identificacao: params[:usuario_token])
        permissao = Permissao.find_by(nome: params[:permissao_nome])

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
        usuario = Usuario.find_by(token_identificacao: params[:usuario_token])
        permissao = Permissao.find_by(nome: params[:permissao_nome])

        if usuario.token_integracao_loja != current_user.token_integracao_loja
            render json: { error: 'Acesso negado' }, status: :forbidden
            return
        end

        usuario.permissoes.delete(permissao)
        render json: { message: 'Permissão removida com sucesso' }
    end

    def disponiveis
        permissoes = ApplicationController::PERMISSOES_POR_ACAO.values.flat_map(&:values).uniq
        render json: permissoes
    end

    # GET /api/v1/permissoes/do_usuario/:usuario_token
    def do_usuario
        Rails.logger.info "Buscando permissões para o usuário com token: #{params[:usuario_token]}"
        usuario = Usuario.find_by(token_identificacao: params[:usuario_token])
        
        if usuario.nil? || usuario.token_integracao_loja != current_user.token_integracao_loja
            render json: { error: 'Usuário não encontrado' }, status: :not_found
            return
        end
        permissoes = UsuarioPermissao.where(
            usuario_token_identificacao: usuario.token_identificacao,
            token_integracao_loja: usuario.token_integracao_loja
        ).includes(:permissao)

        render json: permissoes.map { |up| up.permissao.slice(:nome, :descricao) }
    end

    private

    def permissao_params
        params.require(:permissao).permit(:nome, :descricao)
    end

    def verificar_admin
        unless current_user.admin_loja? || current_user.super_admin?
            render json: { error: 'Acesso negado' }, status: :forbidden
        end
    end
end