class Usuario < ApplicationRecord
  devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :validatable,
       :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  belongs_to :informacao_loja, optional: true
  belongs_to :funcionario, optional: true
  
  has_many :usuarios_permissoes
  has_many :permissoes, through: :usuarios_permissoes
  has_many :vendas, foreign_key: 'id_usuario'
  has_many :historicos_estoque, foreign_key: 'id_usuario'

  enum :tipo_acesso, {
    super_admin: "super_admin",
    admin_loja: "admin_loja", 
    funcionario: "funcionario"
  }, default: :funcionario
  def admin_loja?
    tipo_acesso == 1
  end

  def funcionario?
    tipo_acesso == 2
  end
end
