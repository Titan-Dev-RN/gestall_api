class Assinatura < ApplicationRecord
  belongs_to :informacao_loja 
  belongs_to :plano
  
  has_many :transacoes_pagamento

  audited associated_with: :informacao_loja
  has_associated_audits #:transacoes_pagamento
end