class Fornecedor < ApplicationRecord
  belongs_to :informacao_loja
  
  has_many :estoque_produtos
  
end