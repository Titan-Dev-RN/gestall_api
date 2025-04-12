class Venda < ApplicationRecord
  belongs_to :informacao_loja
  belongs_to :cliente
  belongs_to :usuario
  
  has_many :itens_venda
  has_many :estoque_de_produtos, through: :itens_venda
  has_one :nota_fiscal
end