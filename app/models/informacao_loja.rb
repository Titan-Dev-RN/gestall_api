class InformacaoLoja < ApplicationRecord
    has_many :usuarios
    has_many :funcionarios
    has_many :estoquedeprodutos
    has_many :fornecedores
    has_many :clientes
    has_many :vendas
    has_many :assinaturas
    has_many :notas_fiscais
    has_many :transacoes_pagamento, through: :assinaturas

    def estoque_produtos
        EstoqueDeProduto.where(informacao_loja_id: id)
    end
end
