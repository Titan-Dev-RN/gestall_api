class Funcionario < ApplicationRecord
  belongs_to :informacao_loja
  belongs_to :usuario
end
