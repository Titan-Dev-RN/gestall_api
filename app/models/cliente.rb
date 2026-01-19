class Cliente < ApplicationRecord
  belongs_to :informacao_loja
  
  has_many :vendas
  
  audited associated_with: :informacao_loja
  has_associated_audits #:vendas

  validates :nome, presence: true
end