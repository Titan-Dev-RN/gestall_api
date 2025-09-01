class Api::V1::InformacoesLojasController < ApplicationController
  before_action :set_loja, only: [ :show, :update, :destroy, :reativar ]

  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 10

    @lojas = InformacaoLoja.page(page).per(per_page)
    lojas_com_funcionarios = @lojas.map do |loja|
      funcionarios = Usuario.where(token_integracao_loja: loja.token_integracao)
      {
        loja: loja,
        funcionarios: funcionarios,
        total_funcionarios: funcionarios.count
      }
    end

    render json: {
      lojas: lojas_com_funcionarios,
      current_page: @lojas.current_page,
      total_pages: @lojas.total_pages,
      total_count: @lojas.total_count
    }, status: :ok
  end

  def show
    render json: { loja: @loja, funcionarios: @funcionarios }, status: :ok
  end

  def create
    usuario_params = params.dig(:informacao_loja, :usuario) || {}

    @loja = InformacaoLoja.new(loja_params.except(:usuario))
    @loja.token_integracao = SecureRandom.hex(16)
    @loja.data_de_entrada = Time.current
    @loja.ativo = true

    InformacaoLoja.transaction do
      if @loja.save

        unless @loja.send(:criar_banco_dados)
          raise ActiveRecord::Rollback
        end

        unless @loja.send(:duplicar_para_banco_da_loja)
          raise ActiveRecord::Rollback
        end

        unless @loja.send(:criar_admin_padrao, usuario_params[:password], usuario_params[:password_confirmation])
          raise ActiveRecord::Rollback
        end

        render json: {
          message: "Loja criada com sucesso",
          loja: @loja,
          database_name: "gestall_#{@loja.token_integracao}",
          admin_email: "admin@#{@loja.nome_da_loja.parameterize}.com"
        }, status: :created
      else
        render json: { errors: @loja.errors.full_messages }, status: :unprocessable_entity
      end

    rescue ActiveRecord::Rollback
      render json: { errors: @loja.errors.full_messages }, status: :unprocessable_entity
    rescue => e
      render json: {
        error: "Falha na configuração",
        details: e.message,
        solution: "Contacte o administrador do sistema"
      }, status: :internal_server_error
    end
  end

  def update
    if @loja.update(loja_params)
      render json: @loja
    else
      render json: @loja.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @loja.update(ativo: false)
    render json: { message: "Loja desativada com sucesso" }, status: :ok
  end

  def reativar
    @loja.update(ativo: true)
    render json: { message: "Loja reativada com sucesso" }, status: :ok
  end

  private

  def set_loja
    @loja = InformacaoLoja.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Loja não encontrada" }, status: :not_found
  end

  def loja_params
    params.require(:informacao_loja).permit(
      :nome_da_loja, :nome_dono, :forma_de_pagamento, :endereco,
      :cidade, :estado, :cnpj, :telefone, :email, :plano_contratado, :cep, :inscricao_estadual,
      :data_vencimento_plano, usuario: [ :password, :password_confirmation ]
    )
  end
end
