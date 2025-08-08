class Api::V1::AuditsController < ApplicationController
  
  before_action :teste_super_admin
  before_action :authorize_audit_access
  

  # GET /api/v1/audits
  def index
    @audits = Audited::Audit.all

    @audits = apply_filters(@audits)

    @audits = @audits.order(created_at: :desc)

    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 20
    page = params[:page].to_i > 0 ? params[:page].to_i : 1
    @audits = @audits.page(page).per(per_page) 

    render json: {
      audits: format_audits(@audits),
      meta: {
        total_pages: @audits.total_pages,    
        current_page: @audits.current_page,  
        total_count: @audits.total_count     
      }
    }, status: :ok 
  end

  # GET /api/v1/audits/:id
  def show
    @audit = Audited::Audit.find_by(id: params[:id])

    unless @audit
      render json: { error: 'Auditoria não encontrada' }, status: :not_found and return
    end

    if @current_user.admin_loja? &&
       @audit.associated_type == 'InformacaoLoja' &&
       @audit.associated_id != @current_user.informacao_loja.id 
      render json: { error: 'Acesso negado para esta auditoria.' }, status: :forbidden and return
    end

    render json: format_audit(@audit), status: :ok 
  end

  private 

  def apply_filters(audits_scope)

    if @current_user.admin_loja? && @current_user.informacao_loja
      audits_scope = audits_scope.where(associated_type: 'InformacaoLoja', associated_id: @current_user.informacao_loja.id)

    elsif params[:informacao_loja_id].present? && @current_user.super_admin?
      audits_scope = audits_scope.where(associated_type: 'InformacaoLoja', associated_id: params[:informacao_loja_id])
    end

    if params[:user_id].present?
      audits_scope = audits_scope.where(user_id: params[:user_id])
    end

    if params[:user_type].present?
      audits_scope = audits_scope.where(user_type: params[:user_type])
    end

    if params[:auditable_type].present?
      audits_scope = audits_scope.where(auditable_type: params[:auditable_type])
    end

    if params[:action_type].present?
      audits_scope = audits_scope.where(action: params[:action_type])
    end

    if params[:start_date].present?
      audits_scope = audits_scope.where('created_at >= ?', Date.parse(params[:start_date]).beginning_of_day)
    end
    if params[:end_date].present?
      audits_scope = audits_scope.where('created_at <= ?', Date.parse(params[:end_date]).end_of_day)
    end

    if params[:query].present?
      search_query = "%#{params[:query]}%"
      audits_scope = audits_scope.where("audited_changes::text ILIKE ? OR comment ILIKE ?", search_query, search_query)
    end

    audits_scope 
  end

  def authorize_audit_access
    unless @current_user&.super_admin? || @current_user&.admin_loja?
      render json: { error: 'Acesso negado para visualizar logs de auditoria.' }, status: :forbidden and return
    end

    if @current_user.admin_loja? && @current_user.informacao_loja.nil?
      render json: { error: 'Sua conta de loja não está associada a uma loja ativa para visualizar logs.' }, status: :unprocessable_entity and return
    end
  end

  def teste_super_admin
    @current_user = Usuario.find_by(email: "titan@titan.com")

    unless @current_user
      render json: {error: "Usuário super admin do teste não foi encontrado"}
    end
  end

  def format_audit(audit)
    {
      id: audit.id,
      auditable_type: audit.auditable_type,
      auditable_id: audit.auditable_id,
      action: audit.action,
      user_id: audit.user_id,
      user_type: audit.user_type,
      user_email: audit.user&.email, 
      remote_address: audit.remote_address,
      version: audit.version,
      audited_changes: audit.audited_changes, 
      associated_type: audit.associated_type,
      associated_id: audit.associated_id,
      comment: audit.comment,
      created_at: audit.created_at
    }
  end

  def format_audits(audits)
    audits.map { |audit| format_audit(audit) }
  end
end