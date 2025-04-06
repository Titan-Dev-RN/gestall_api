class Loja < ApplicationRecord
  has_many :usuarios
  has_many :produtos_estoques
  has_many :assinaturas
  has_many :transacoes_pagamento, through: :assinaturas
end
