class UsuarioPermissao < ApplicationRecord
  belongs_to :usuario
  belongs_to :permissao

  validates :usuario_id, uniqueness: { scope: :permissao_id }

  audited associated_with: :usuario
end