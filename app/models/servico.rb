class Servico < ApplicationRecord
    validates :nome, presence: true
    validates :preco, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :descricao, presence: true
end
