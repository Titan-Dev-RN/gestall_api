class HistoricoEstoque < ApplicationRecord
  belongs_to :estoque_de_produto, foreign_key: 'estoque_de_produto_id', class_name: 'EstoqueDeProduto'
  belongs_to :informacao_loja
  belongs_to :usuario
end