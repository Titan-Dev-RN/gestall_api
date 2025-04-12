class VendaSerializer < ActiveModel::Serializer
    attributes :id, :data_venda, :valor_total, :status, :forma_pagamento
    
    has_many :itens_venda
    belongs_to :cliente
    belongs_to :usuario
  end