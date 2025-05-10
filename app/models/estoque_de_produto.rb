class EstoqueDeProduto < ApplicationRecord
  belongs_to :informacao_loja
  belongs_to :fornecedor, optional: true
  has_many :categorias
  has_many :historico_estoques
  has_many :itens_venda, foreign_key: 'estoque_de_produto_id'
end