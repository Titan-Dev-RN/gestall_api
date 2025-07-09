class Api::V1::ProdutosController < ApplicationController
  before_action :set_produto, only: [:show, :update, :destroy, :reativar_produto, :adicionar_estoque, :remover_estoque]

  def index
    @produtos = current_loja.estoque_produtos
    render json: @produtos
  end

  def show
    render json: @produto.as_json.merge(nivel_permissao: @current_user.tipo_acesso)
  end
  # POST /api/v1/produtos
  def create
    @produto = current_loja.estoque_produtos.new(produto_params)
    @produto.fornecedor_id ||= nil
    if @produto.save
      HistoricoEstoque.create(
        estoque_de_produto_id: @produto.id,
        informacao_loja_id: current_loja.id,
        usuario_token_identificacao: @current_user.token_identificacao,
        tipo_movimentacao: 'cadastro',
        quantidade: @produto.quantidade_em_estoque,
        data_movimentacao: Time.current,
        observacao: "Cadastro inicial do produto"
      )
      render json: @produto.as_json.merge(nivel_permissao: @current_user.tipo_acesso), status: :created
    else
      render json: @produto.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/produtos/1
  def update
    if @produto.update(produto_params)
      render json: @produto
    else
      render json: @produto.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/produtos/1
  def destroy
    @produto.update(ativo: false)
    HistoricoEstoque.create(
      estoque_de_produto_id: @produto.id,
      informacao_loja_id: current_loja.id,
      usuario_token_identificacao: @current_user.token_identificacao,
      tipo_movimentacao: 'desativacao',
      quantidade: @produto.quantidade_em_estoque,
      data_movimentacao: Time.current,
      observacao: "Produto desativado"
    )

    render json: { message: 'Produto desativado com sucesso'}, status: :ok
  end

  def reativar_produto
    @produto.update(ativo: true)

    HistoricoEstoque.create(
      estoque_de_produto_id: @produto.id,
      informacao_loja_id: current_loja.id,
      usuario_token_identificacao: @current_user.token_identificacao,
      tipo_movimentacao: 'reativacao',
      quantidade: @produto.quantidade_em_estoque,
      data_movimentacao: Time.current,
      observacao: "Produto reativado"
    )
    render json: { message: 'produto reativado com sucesso'}, status: :ok
  end

  # GET /api/v1/produtos/baixo_estoque
  def baixo_estoque
    @produtos = current_loja.estoque_produtos.where('quantidade_em_estoque < quantidade_minima')
    render json: @produtos
  end

  def adicionar_estoque
    quantidade = params[:quantidade].to_i
    observacao = params[:observacao]
    
    if quantidade <= 0
      render json: { error: 'Quantidade deve ser maior que zero' }, status: :unprocessable_entity
      return
    end

    @produto.increment!(:quantidade_em_estoque, quantidade)
    
    HistoricoEstoque.create(
      estoque_de_produto_id: @produto.id,
      informacao_loja_id: current_loja.id,
      usuario_token_identificacao: @current_user.token_identificacao,
      tipo_movimentacao: 'entrada',
      quantidade: quantidade,
      data_movimentacao: Time.current,
      observacao: observacao || "Entrada de estoque manual"
    )
    
    render json: { 
      message: 'Estoque adicionado com sucesso',
      produto: @produto.reload,
      historico: HistoricoEstoque.last
    }, status: :ok
  end

  def criar_categoria
    @categoria = Categoria.new(categoria_params)
    if @categoria.save
      render json: @categoria, status: :created
    else
      render json: @categoria.errors, status: :unprocessable_entity
    end
  end

  def categoria_params
    params.require(:categoria).permit(:nome)
  end

  def remover_estoque
    quantidade = params[:quantidade].to_i
    observacao = params[:observacao]
    
    if quantidade <= 0
      render json: { error: 'Quantidade deve ser maior que zero' }, status: :unprocessable_entity
      return
    end

    if @produto.quantidade_em_estoque < quantidade
      render json: { error: 'Quantidade em estoque insuficiente' }, status: :unprocessable_entity
      return
    end

    @produto.decrement!(:quantidade_em_estoque, quantidade)
    
    HistoricoEstoque.create(
      estoque_de_produto_id: @produto.id,
      informacao_loja_id: current_loja.id,
      usuario_token_identificacao: @current_user.token_identificacao,
      tipo_movimentacao: 'saida',
      quantidade: quantidade,
      data_movimentacao: Time.current,
      observacao: observacao || "Saída de estoque manual"
    )
    
    render json: { 
      message: 'Estoque removido com sucesso',
      produto: @produto.reload,
      historico: HistoricoEstoque.last
    }, status: :ok
  end

  private


  def set_produto
    @produto = current_loja.estoque_produtos.find(params[:id])
  end

  def current_loja
    @current_loja ||= InformacaoLoja.find_by(token_integracao: @current_user.token_integracao_loja)
  end
  
  def produto_params
    params.require(:produto).permit(
      :nome_do_produto, :categoria_do_produto, :tipo_do_produto,
      :quantidade_em_estoque, :quantidade_minima, :quantidade_maxima,
      :preco_de_venda, :codigo_barras, :codigo_interno,
      :unidade_medida, :peso, :marca, :fornecedor_id, :ativo,
    )
  end
  
end