class InformacaoLoja < ApplicationRecord
    has_many :usuarios
    has_many :funcionarios
    has_many :estoque_produtos
    has_many :fornecedores
    has_many :clientes
    has_many :vendas
    has_many :assinaturas
    has_many :notas_fiscais
    has_many :transacoes_pagamento, through: :assinaturas
end
