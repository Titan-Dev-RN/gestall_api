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

  after_create :criar_banco_dados, if: -> { Rails.env.development? || Rails.env.production? }

  validates :cnpj, presence: true, uniqueness: true
  validates :nome_da_loja, :email, presence: true

  def estoque_produtos
    EstoqueDeProduto.where(informacao_loja_id: id)
  end

  private

  def criar_banco_dados
    InformacoesLojasController.new.send(:criar_banco_loja, self)
  rescue => e
    Rails.logger.error "Falha ao criar banco para loja #{id}: #{e.message}"
    # Em produção, notificar administrador
  end
end