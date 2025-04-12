class Api::V1::VendasController < ApplicationController
    before_action :authorize_vendedor
    before_action :set_venda, only: [:show, :adicionar_item, :remover_item, :finalizar, :cancelar]
  
    # GET /api/v1/vendas
    def index
      @vendas = current_vendedor.vendas
      render json: @vendas, include: [:itens_venda, :cliente]
    end
  
    # POST /api/v1/vendas
    def create
      @venda = current_vendedor.vendas.new(venda_params)
      
      if @venda.save
        render json: @venda, status: :created
      else
        render json: @venda.errors, status: :unprocessable_entity
      end
    end
  
    # POST /api/v1/vendas/1/adicionar_item
    def adicionar_item
      produto = current_loja.estoque_de_produtos.find(params[:produto_id])
      
      @item = @venda.itens_venda.new(
        estoque_de_produto_id: produto.id,
        quantidade: params[:quantidade],
        valor_unitario: produto.preco_de_venda,
        desconto: params[:desconto] || 0
      )
      
      if @item.save
        render json: @venda.reload
      else
        render json: @item.errors, status: :unprocessable_entity
      end
    end
  
    # POST /api/v1/vendas/1/finalizar
    def finalizar
      if @venda.update(status: 'finalizada', valor_total: calcular_total)
        atualizar_estoque
        render json: @venda
      else
        render json: @venda.errors, status: :unprocessable_entity
      end
    end
  
    private
    
    def set_venda
      @venda = current_vendedor.vendas.find(params[:id])
    end
  
    def venda_params
      params.require(:venda).permit(:cliente_id, :observacoes, :forma_pagamento)
    end
  
    def current_vendedor
      current_user.funcionario
    end
  
    def current_loja
      current_vendedor.informacao_loja
    end
  
    def calcular_total
      @venda.itens_venda.sum(:valor_total) - @venda.desconto.to_f
    end
  
    def atualizar_estoque
      @venda.itens_venda.each do |item|
        produto = item.estoque_de_produto
        produto.decrement!(:quantidade_em_estoque, item.quantidade)
      end
    end
  end