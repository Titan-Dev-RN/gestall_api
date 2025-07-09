class HistoricoEstoque < ApplicationRecord
  belongs_to :estoque_de_produto, foreign_key: 'estoque_de_produto_id', class_name: 'EstoqueDeProduto'
  belongs_to :informacao_loja
  belongs_to :usuario, foreign_key: 'usuario_token_identificacao', primary_key: 'token_identificacao', optional: true
end