class Sessao < ApplicationRecord
    belongs_to :usuario, foreign_key: :usuario_token_identificacao, primary_key: :token_integracao
    belongs_to :informacao_loja, foreign_key: :informacao_loja_token, primary_key: :token_integracao
    has_many :vendas
end
