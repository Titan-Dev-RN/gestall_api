class Usuario < ApplicationRecord
  devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :validatable,
       :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  belongs_to :loja, optional: true
  has_many :usuario_permissoes
  has_many :permissoes, through: :usuario_permissoes
end
