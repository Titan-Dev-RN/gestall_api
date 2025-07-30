class TransacaoPagamento < ApplicationRecord
  belongs_to :assinatura

  audited associated_with: :assinatura
end