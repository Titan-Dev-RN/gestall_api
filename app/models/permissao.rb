class Permissao < ApplicationRecord
    has_many :usuarios_permissoes
    has_many :usuarios, through: :usuarios_permissoes
    
    validates :nome, presence: true, uniqueness: true
    
    # Método útil para atribuir permissões:
    def self.atribuir(usuario_id, permissao_id)
      UsuarioPermissao.find_or_create_by(usuario_id: usuario_id, permissao_id: permissao_id)
    end
    
    # Exemplo de permissões padrão:
    DEFAULT_PERMISSIONS = [
      { nome: 'gerenciar_loja', descricao: 'Pode editar informações da loja' },
      { nome: 'gerenciar_produtos', descricao: 'Pode gerenciar estoque' }
    ]
  end