class Api::V1::VendasController < ApplicationController
  before_action :authorize_vendedor
  before_action :set_venda, only: [:show, :adicionar_item, :remover_item, :finalizar, :cancelar, :aumentar_quantidade, :atualizar_desconto_item]

  def index
    @vendas = vendas_loja(@current_user.id)
    render json: @vendas, include: [:itens_venda, :cliente]
  end
    
  def show
    render json: @venda, include: [:itens_venda, :cliente]
  end
  # GET /api/v1/vendas/vendas_all
  def index_all
    @vendas = Venda.where(informacao_loja_id: @current_user.informacao_loja.id)
    render json: @vendas, include: [:itens_venda, :cliente]
  end
  # POST /api/v1/vendas
  def create
    loja = InformacaoLoja.find_by(token_integracao: @current_user.token_integracao_loja)
    
    @venda = @current_user.vendas.new(
      cliente_id: params[:cliente_id],
      observacoes: params[:observacoes],
      forma_pagamento: params[:forma_pagamento],
      data_venda: Time.current,
      status: 'aberta',
      desconto: 0,
      valor_total: 0,
      informacao_loja_id: loja.id
    )
  
    if @venda.save
      render json: @venda, status: :created
    else
      render json: @venda.errors, status: :unprocessable_entity
    end
  end
    
  # POST /api/v1/vendas/1/adicionar_item
  def adicionar_item
    codigo_de_barras = params[:codigo_barras]
    produto = @current_user.informacao_loja.estoque_produtos.find_by(codigo_barras: codigo_de_barras)
  
    unless produto
      render json: { error: 'Produto não encontrado no estoque' }, status: :not_found and return
    end
  
    item_existente = @venda.itens_venda.find_by(estoque_de_produto_id: produto.id)
  
    if item_existente
      nova_quantidade = params[:quantidade].to_i
      desconto = params[:desconto].to_f || item_existente.desconto
      
      item_existente.update(
        quantidade: nova_quantidade,
        desconto: desconto,
        valor_total: (produto.preco_de_venda * nova_quantidade) - desconto
      )
  
      if item_existente.save
        @venda.update(valor_total: calcular_total)
        render json: { 
          action: 'updated', 
          venda: @venda.reload.as_json(include: :itens_venda) 
        }
      else
        render json: item_existente.errors, status: :unprocessable_entity
      end
    else
      quantidade = params[:quantidade].to_i
      desconto = params[:desconto].to_f || 0.0
      valor_unitario = produto.preco_de_venda
      valor_total = (valor_unitario * quantidade) - desconto
  
      @item = @venda.itens_venda.new(
        estoque_de_produto_id: produto.id,
        quantidade: quantidade,
        valor_unitario: valor_unitario,
        desconto: desconto,
        valor_total: valor_total
      )
  
      if @item.save
        @venda.update(valor_total: calcular_total)
        render json: { 
          action: 'created', 
          venda: @venda.reload.as_json(include: :itens_venda) 
        }
      else
        render json: @item.errors, status: :unprocessable_entity
      end
    end
  end

  def atualizar_desconto_item
    codigo_de_barras = params[:codigo_barras]
    item = @venda.itens_venda.joins(:estoque_de_produto).find_by(estoque_de_produtos: { codigo_barras: codigo_de_barras })
    unless item
      render json: { error: 'Item não encontrado na venda' }, status: :not_found and return
    end
    novo_desconto = params[:desconto]
    if item.update(desconto: novo_desconto)
      @venda.update(valor_total: calcular_total)
      render json: { message: 'Desconto atualizado com sucesso', venda: @venda.reload.as_json(include: :itens_venda) }, status: :ok
    else
      render json: item.errors, status: :unprocessable_entity
    end
  end

  def aumentar_quantidade
    codigo_de_barras = params[:codigo_barras]
    item = @venda.itens_venda.joins(:estoque_de_produto).find_by(estoque_de_produtos: { codigo_barras: codigo_de_barras })

    unless item
      render json: { error: 'Item não encontrado na venda' }, status: :not_found and return
    end

    quantidade_adicional = params[:quantidade].to_i
    nova_quantidade = item.quantidade + quantidade_adicional
    valor_total = (item.valor_unitario * nova_quantidade) - item.desconto

    if item.update(quantidade: nova_quantidade, valor_total: valor_total)
    @venda.update(valor_total: calcular_total)
    render json: { message: 'Quantidade aumentada com sucesso', venda: @venda.reload.as_json(include: :itens_venda) }, status: :ok
    else
    render json: item.errors, status: :unprocessable_entity
    end
  end
  #DELETE api/v1/vendas/:venda_id/remover_item/:item_id
  def remover_item
    item = @venda.itens_venda.find_by(id: params[:item_id])
    
    unless item
    render json: { error: 'Item não encontrado' }, status: :not_found and return
    end

    if item.destroy
      @venda.update(valor_total: calcular_total)
      render json: { message: 'Item removido com sucesso', venda: @venda.reload, itens_venda: @venda.itens_venda }, status: :ok
    else
    render json: { error: 'Erro ao remover item' }, status: :unprocessable_entity
    end
  end
  
  # POST /api/v1/vendas/1/finalizar
  def finalizar
    if params[:forma_pagamento] == nil
      render json: { error: 'Forma de pagamento não informada' }, status: :unprocessable_entity and return
    end
    @venda.valor_total = calcular_total
    @venda.status = 'finalizada'
    @venda.forma_pagamento = params[:forma_pagamento]
    if params[:cliente] != nil
      @venda.cliente_id = params[:cliente]
    end
    if @venda.save
      atualizar_estoque
      render json: @venda
    else
      render json: @venda.errors, status: :unprocessable_entity
    end
  end
  

  def cancelar
    if @venda.update(status: 'cancelada')
      render json: @venda
    else
      render json: @venda.errors, status: :unprocessable_entity
    end
  end

  private
  def authorize_vendedor
    unless (@current_user.funcionario? && @current_user.token_integracao_loja) || 
          (@current_user.admin_loja? && @current_user.token_integracao_loja)
      render json: { error: 'Acesso não autorizado' }, status: :forbidden
    end
  end

  def set_venda
    loja = InformacaoLoja.find_by(token_integracao: @current_user.token_integracao_loja)
    @venda = loja.vendas.find(params[:id])
  end

  def venda_params
    params.require(:venda).permit(
      :cliente,
      :cliente_id, :valor_total, :forma_pagamento,
      itens_venda: [:produto_id, :quantidade, :preco_unitario]
    )
  end

  def calcular_total
    @venda.itens_venda.sum('valor_total') - @venda.desconto.to_f
  end
    
  
  def atualizar_estoque
    @venda.itens_venda.each do |item|
      produto = item.estoque_de_produto
      produto.decrement!(:quantidade_em_estoque, item.quantidade)
      
      HistoricoEstoque.create(
        estoque_de_produto_id: @produto.id,
        informacao_loja_id: current_loja.id,
        usuario_id: @current_user.id,
        tipo_movimentacao: 'venda',
        quantidade: item.quantidade,
        data_movimentacao: Time.current,
        observacao: "Venda ##{@venda.id} - #{item.quantidade} unidades vendidas"
      )
    end
  end

  def vendas_loja(vendedor_id)
    @vendedor = Usuario.find(vendedor_id)
    loja = InformacaoLoja.find_by(token_integracao: @vendedor.token_integracao_loja)
    
    if @vendedor.funcionario? && loja
      @vendas = Venda.where(informacao_loja_id: loja.id, usuario_id: vendedor_id)
    elsif @vendedor.admin_loja? && loja
      @vendas = Venda.where(informacao_loja_id: loja.id)
    else
      render json: { error: 'Acesso não autorizado' }, status: :forbidden
    end
  end
end