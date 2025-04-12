class ItemVenda < ApplicationRecord
  belongs_to :venda
  belongs_to :estoque_de_produto, foreign_key: 'estoque_de_produto_id', class_name: 'EstoqueDeProduto'
  
  validates :quantidade, :valor_unitario, presence: true
  validates :estoque_de_produto, presence: true
end