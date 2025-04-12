class HistoricoEstoque < ApplicationRecord
  belongs_to :produto, class_name: 'EstoqueDeProduto', foreign_key: 'id_produto'
  belongs_to :informacao_loja
  belongs_to :usuario
end