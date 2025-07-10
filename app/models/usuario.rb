class Usuario < ApplicationRecord
  devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :validatable,
       :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  self.primary_key = :id

  belongs_to :informacao_loja, 
             optional: true, 
             foreign_key: :token_integracao_loja, 
             primary_key: :token_integracao
             
  belongs_to :funcionario, optional: true
  
  before_create :set_uuid

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
    InformacaoLoja.find_by(token_integracao: token_integracao_loja)
  end

  def admin_loja?
    tipo_acesso == "admin_loja"
  end

  def funcionario?
    tipo_acesso == "funcionario"
  end

  def tem_permissao?(permissao_nome)
    return true if super_admin?
    
    return true if admin_loja? && !permissao_nome.start_with?('super_')
    
    permissoes.exists?(nome: permissao_nome)
  end

  def tem_permissoes?(*permissoes_nomes)
    permissoes_nomes.all? { |pn| tem_permissao?(pn) }
  end

  def tem_alguma_permissao?(*permissoes_nomes)
    permissoes_nomes.any? { |pn| tem_permissao?(pn) }
  end

  private 

  def set_uuid
    self.id ||= SecureRandom.uuid
  end
end
