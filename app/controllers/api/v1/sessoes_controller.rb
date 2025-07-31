class Api::V1::SessoesController < ApplicationController
  before_action :ensure_no_active_session, only: [:iniciar_sessao]
  before_action :set_sessao, only: [:encerrar_sessao, :show]

  def iniciar_sessao
    # Encerra qualquer sessão anterior não encerrada do mesmo usuário
    Sessao.where(
      usuario_token_identificacao: @current_user.token_identificacao,
      informacao_loja_token: @current_user.token_integracao_loja,
      fim: nil
    ).update_all(fim: Time.current)
    
    @sessao = Sessao.new(
      usuario_token_identificacao: @current_user.token_identificacao,
      informacao_loja_token: @current_user.token_integracao_loja,
      inicio: Time.current
    )
    
    if @sessao.save
      render json: @sessao, status: :created
    else
      render json: @sessao.errors, status: :unprocessable_entity
    end
  end

  def encerrar_sessao
    if @sessao.fim.present?
      render json: { error: 'Sessão já encerrada' }, status: :unprocessable_entity
      return
    end

    @sessao.fim = Time.current
    if @sessao.save
      render json: @sessao, status: :ok
    else
      render json: @sessao.errors, status: :unprocessable_entity
    end
  end

  def index 
    if @current_user.admin_loja?
      @sessoes = Sessao.where(informacao_loja_token: @current_user.token_integracao_loja)
                       .order(created_at: :desc)
    else
      @sessoes = Sessao.where(
        usuario_token_identificacao: @current_user.token_identificacao,
        informacao_loja_token: @current_user.token_integracao_loja
      ).order(created_at: :desc)
    end
    render json: @sessoes
  end

  def show
    if @sessao
      render json: @sessao.as_json(include: { vendas: { include: [:itens_venda, :cliente] } })
    else
      render json: { error: 'Sessão não encontrada' }, status: :not_found
    end
  end

  def verificar_sessao
    sessao_ativa = Sessao.find_by(
      usuario_token_identificacao: @current_user.token_identificacao,
      informacao_loja_token: @current_user.token_integracao_loja,
      fim: nil
    )
    
    if sessao_ativa
      render json: { ativa: true, sessao: sessao_ativa }
    else
      render json: { ativa: false }
    end
  end

  private

  def set_sessao
    @sessao = if @current_user.admin_loja?
                Sessao.find_by(
                  id: params[:id],
                  informacao_loja_token: @current_user.token_integracao_loja
                )
              else
                Sessao.find_by(
                  id: params[:id],
                  usuario_token_identificacao: @current_user.token_identificacao,
                  informacao_loja_token: @current_user.token_integracao_loja
                )
              end
    
    unless @sessao
      render json: { error: 'Sessão não encontrada ou acesso não autorizado' }, 
             status: :not_found
    end
  end

  def ensure_no_active_session
    if Sessao.exists?(
      usuario_token_identificacao: @current_user.token_identificacao,
      informacao_loja_token: @current_user.token_integracao_loja,
      fim: nil
    )
      render json: { error: 'Já existe uma sessão ativa' }, status: :conflict
    end
  end
end