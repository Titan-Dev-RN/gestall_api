class Venda < ApplicationRecord
  belongs_to :informacao_loja
  belongs_to :cliente
  belongs_to :usuario
end
