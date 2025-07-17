class NotaFiscal < ApplicationRecord
  belongs_to :venda
  belongs_to :informacao_loja

  audited associated_with: [:venda, :informacao_loja]
end