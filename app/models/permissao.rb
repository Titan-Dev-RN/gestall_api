class Permissao < ApplicationRecord
    self.table_name = 'permissoes'

    belongs_to :informacao_loja, 
                foreign_key: :token_integracao_loja, 
                primary_key: :token_integracao,
                optional: true

    has_and_belongs_to_many :usuarios,
                            join_table: 'usuarios_permissoes',
                            association_foreign_key: 'usuario_token_identificacao',
                            foreign_key: 'permissao_token'

    validates :token, presence: true, uniqueness: { scope: :token_integracao_loja }
    validates :nome, presence: true, uniqueness: { scope: :token_integracao_loja }
    validates :descricao, presence: true

    before_create :set_tokens

    private

    def set_tokens
        self.token ||= SecureRandom.hex(16)
        self.token_integracao_loja ||= informacao_loja&.token_integracao
    end
end