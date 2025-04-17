class Usuario < ApplicationRecord
  devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :validatable,
       :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  belongs_to :informacao_loja, optional: true
  belongs_to :funcionario, optional: true
  
  has_many :usuarios_permissoes
  has_many :permissoes, through: :usuarios_permissoes
  has_many :vendas, foreign_key: 'usuario_id'
  has_many :historicos_estoque, foreign_key: 'usuario_id'

  enum :tipo_acesso, {
    super_admin: "super_admin",
    admin_loja: "admin_loja", 
    funcionario: "funcionario"
  }, default: :funcionario

  def informacao_loja
    InformacaoLoja.find_by(id: id_loja)
    
  end
  def admin_loja?
    puts "entrou no admin_loja?"
    puts "tipo_acesso: #{tipo_acesso}"
    tipo_acesso == "admin_loja"
  end

  def funcionario?
    puts "entrou no funcionario?"
    puts "tipo_acesso: #{tipo_acesso}"
    tipo_acesso == "funcionario"
  end
end
