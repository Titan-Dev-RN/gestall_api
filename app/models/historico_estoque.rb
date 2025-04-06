class HistoricoEstoque < ApplicationRecord
  belongs_to :estoque_de_produto
  belongs_to :informacao_loja
  belongs_to :usuario
end
