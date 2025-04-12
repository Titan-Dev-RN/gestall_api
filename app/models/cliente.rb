class Cliente < ApplicationRecord
  belongs_to :informacao_loja
  
  has_many :vendas
  
end