class Assinatura < ApplicationRecord
  belongs_to :informacao_loja 
  belongs_to :plano
  
  has_many :transacoes_pagamento
end