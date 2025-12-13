class VendaSerializer < ActiveModel::Serializer
    attributes :id, :data_venda, :valor_total, :status, :forma_pagamento, :cliente_id, :usuario_token_identificacao, :informacao_loja_token, :desconto, :created_at, :updated_at

    has_many :itens_venda
  end