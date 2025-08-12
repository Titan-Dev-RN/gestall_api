class Api::V1::PermissoesController < ApplicationController
    before_action :verificar_admin

    def index
        permissoes = Permissao.where(token_integracao_loja: current_user.token_integracao_loja)
        render json: permissoes
    end

    def atribuir
        # Encontra o usuário
        usuario = Usuario.find_by(token_identificacao: params[:usuario_token])
        
        # Verifica se o usuário pertence ao mesmo tenant
        if usuario.nil? || usuario.token_integracao_loja != current_user.token_integracao_loja
            render json: { error: 'Acesso negado' }, status: :forbidden
            return
        end

        # Espera um array de nomes de permissões no formato:
        # { "usuario_token": "abc123", "permissoes": ["permissao1", "permissao2"] }
        permissoes = params[:permissoes] || []
        
        # Encontra todas as permissões de uma vez
        permissoes_encontradas = Permissao.where(
            nome: permissoes,
            token_integracao_loja: current_user.token_integracao_loja
        )

        # Prepara os registros para inserção em massa
        registros = permissoes_encontradas.map do |permissao|
            {
            usuario_token_identificacao: usuario.token_identificacao,
            permissao_token: permissao.token,
            token_integracao_loja: usuario.token_integracao_loja,
            created_at: Time.current,
            updated_at: Time.current
            }
        end

        # Insere em massa ignorando duplicatas
        UsuarioPermissao.insert_all(
            registros,
            unique_by: [:usuario_token_identificacao, :permissao_token, :token_integracao_loja]
        )

        render json: { 
            message: 'Permissões atribuídas com sucesso',
            atribuidas: permissoes_encontradas.pluck(:nome),
            nao_encontradas: permissoes - permissoes_encontradas.pluck(:nome)
        }
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