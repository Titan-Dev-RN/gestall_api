class EstoqueDeProduto < ApplicationRecord
  belongs_to :informacao_loja
  belongs_to :fornecedor
end
