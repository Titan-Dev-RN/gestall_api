class UsuarioPermissao < ApplicationRecord
  belongs_to :usuario
  belongs_to :permissao
end
