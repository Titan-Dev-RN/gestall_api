class Api::V1::ProdutosController < ApplicationController
    before_action :authorize_loja_admin, only: [:create, :update, :destroy]

    before_action :set_produto, only: [:show, :update, :destroy]
    
    # GET /api/v1/produtos
    def index
      @produtos = current_loja.estoque_produtos
      render json: @produtos
    end
    
    def show
      render json: @produto
    end
    # POST /api/v1/produtos
    def create
      @produto = current_loja.estoque_produtos.new(produto_params)
      
      if @produto.save
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
      render json: { message: 'Produto desativado com sucesso', nivel_permissao: @current_user.tipo_acesso }, status: :ok
    end
  
    # GET /api/v1/produtos/baixo_estoque
    def baixo_estoque
      @produtos = current_loja.estoque_produtos
                            .where('quantidade_em_estoque < quantidade_minima')
      render json: @produtos
    end
  
    private
    def authorize_loja_admin
        unless @current_user.admin_loja? && @current_user.informacao_loja
            render json: { error: 'Acesso não autorizado' }, status: :forbidden
        end
    end

    def set_produto
      @produto = current_loja.estoque_produtos.find(params[:id])
    end
  
    def produto_params
      params.require(:produto).permit(
        :nome_do_produto, :categoria_do_produto, :tipo_do_produto,
        :quantidade_em_estoque, :quantidade_minima, :quantidade_maxima,
        :preco_de_venda, :codigo_barras, :codigo_interno,
        :unidade_medida, :peso, :marca, :fornecedor_id, :ativo,
      )
    end
  
    def current_loja
      @current_user.informacao_loja
    end
  end