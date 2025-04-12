class ProdutoSerializer < ActiveModel::Serializer
    attributes :id, :nome_do_produto, :categoria_do_produto, :preco_de_venda,
               :quantidade_em_estoque, :codigo_barras, :marca
    
    belongs_to :fornecedor
  end