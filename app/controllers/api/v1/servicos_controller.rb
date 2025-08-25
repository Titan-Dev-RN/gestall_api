class Api::V1::ServicosController < ApplicationController
  before_action :set_servico, only: %i[ show update destroy ]

  # GET /servicos
  def index
    @servicos = Servico.all

    render json: @servicos
  end

  # GET /servicos/1
  def show
    render json: @servico
  end

  # POST /servicos
  def create
    @servico = Servico.new(servico_params)

    if @servico.save
      render json: @servico, status: :created, location: @servico
    else
      render json: @servico.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /servicos/1
  def update
    if @servico.update(servico_params)
      render json: @servico
    else
      render json: @servico.errors, status: :unprocessable_entity
    end
  end

  # DELETE /servicos/1
  def destroy
    @servico.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_servico
      @servico = Servico.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def servico_params
      params.fetch(:servico, {})
    end
end
