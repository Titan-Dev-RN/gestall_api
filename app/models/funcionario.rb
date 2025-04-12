class Funcionario < ApplicationRecord
  belongs_to :informacao_loja
  belongs_to :usuario, optional: true
  
  has_many :vendas, foreign_key: 'id_usuario'
end
