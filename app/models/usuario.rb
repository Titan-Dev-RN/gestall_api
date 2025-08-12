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

  has_many :vendas, foreign_key: 'usuario_id'
  has_many :historicos_estoque, foreign_key: 'usuario_id'

  audited except: [:encrypted_password, :token_integracao_loja]
  audited associated_with: :informacao_loja
  has_associated_audits # :vendas, :historicos_estoque

  has_and_belongs_to_many :permissoes,
                        join_table: 'usuarios_permissoes',
                        foreign_key: 'usuario_token_identificacao',
                        association_foreign_key: 'permissao_token'


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
    
    return true if admin_loja?
    # Busca a permissão específica do tenant
    permissao = Permissao.find_by(
      nome: permissao_nome,
      token_integracao_loja: token_integracao_loja
    )
    
    return false unless permissao
    
    # Verifica se o usuário tem essa permissão
    permissoes.exists?(token: permissao.token)
  end

  def atribuir_permissoes(*nomes_permissoes)
    nomes_permissoes.each do |nome|
      permissao = Permissao.find_or_create_by(
        nome: nome,
        token_integracao_loja: token_integracao_loja
      ) do |p|
        p.descricao = I18n.t("permissoes.#{nome}", default: nome.humanize)
      end
      
      unless permissoes.exists?(token: permissao.token)
        UsuarioPermissao.create(
          usuario_token_identificacao: token_identificacao,
          permissao_token: permissao.token,
          token_integracao_loja: token_integracao_loja
        )
      end
    end
  end

  def remover_permissoes(*nomes_permissoes)
    permissoes.where(
      nome: nomes_permissoes,
      token_integracao_loja: token_integracao_loja
    ).each do |permissao|
      UsuarioPermissao.where(
        usuario_token_identificacao: token_identificacao,
        permissao_token: permissao.token
      ).delete_all
    end
  end
  
  private 

  def set_uuid
    self.id ||= SecureRandom.uuid
  end
end
