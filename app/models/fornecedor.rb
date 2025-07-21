class Fornecedor < ApplicationRecord
  belongs_to :informacao_loja
  
  has_many :estoque_produtos

  audited associated_with: :informacao_loja
  has_associated_audits #:estoque_produtos
  
end