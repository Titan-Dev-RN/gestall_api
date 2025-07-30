class Plano < ApplicationRecord
    has_many :assinaturas
  
    validates :nome, :valor_mensal, presence: true

    audited
    has_associated_audits
end