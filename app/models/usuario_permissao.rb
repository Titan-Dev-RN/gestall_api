class UsuarioPermissao < ApplicationRecord
  self.table_name = 'usuarios_permissoes'

  belongs_to :usuario,
             primary_key: :token_identificacao,
             foreign_key: :usuario_token_identificacao

  belongs_to :permissao,
             primary_key: :token,
             foreign_key: :permissao_token

  before_create :set_tokens

  private

  def set_tokens
    self.token_integracao_loja ||= usuario&.token_integracao_loja
  end
end