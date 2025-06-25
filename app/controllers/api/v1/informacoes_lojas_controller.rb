class Api::V1::InformacoesLojasController < ApplicationController
  before_action :authorize_super_admin, only: [:create, :update, :destroy]
  before_action :set_loja, only: [:show, :update, :destroy, :reativar]

  # GET /api/v1/informacoes_lojas
  def index
    @lojas = InformacaoLoja.all
    render json: @lojas, status: :ok
  end

  # GET /api/v1/informacoes_lojas/1
  def show
    render json: @loja
  end

  # POST /api/v1/informacoes_lojas
  def create
    @loja = InformacaoLoja.new(loja_params)
    @loja.token_integracao = SecureRandom.hex(16)
    @loja.data_de_entrada = Time.current
    @loja.ativo = true

    if @loja.save
      render json: {
        message: 'Loja criada com sucesso',
        loja: @loja,
        database_name: "gestall_#{@loja.token_integracao}",
        admin_email: "admin@#{@loja.nome_da_loja.parameterize}.com"
      }, status: :created
    else
      render json: { errors: @loja.errors.full_messages }, status: :unprocessable_entity
    end
  rescue => e
    @loja.destroy if @loja.persisted?
    render json: {
      error: 'Falha na configuração',
      details: e.message,
      solution: 'Contacte o administrador do sistema'
    }, status: :internal_server_error
  end

  # PATCH/PUT /api/v1/informacoes_lojas/1
  def update
    if @loja.update(loja_params)
      render json: @loja
    else
      render json: @loja.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/informacoes_lojas/1
  def destroy
    @loja.update(ativo: false)
    render json: { message: 'Loja desativada com sucesso' }, status: :ok
  end

  # POST /api/v1/informacoes_lojas/1/reativar
  def reativar
    @loja.update(ativo: true)
    render json: { message: 'Loja reativada com sucesso' }, status: :ok
  end

  private

  def set_loja
    @loja = InformacaoLoja.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Loja não encontrada' }, status: :not_found
  end

  def loja_params
    params.require(:informacao_loja).permit(
      :nome_da_loja, :nome_dono, :forma_de_pagamento, :endereco, 
      :cidade, :estado, :cnpj, :telefone, :email, :plano_contratado,
      :data_vencimento_plano
    )
  end

  def authorize_super_admin
    unless @current_user&.super_admin?
      render json: { error: 'Acesso não autorizado' }, status: :forbidden
    end
  end

end