class NotaFiscal < ApplicationRecord
  belongs_to :venda
  belongs_to :informacao_loja
end
