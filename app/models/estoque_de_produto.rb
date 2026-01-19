class EstoqueDeProduto < ApplicationRecord
  belongs_to :informacao_loja
  belongs_to :fornecedor, optional: true
  has_many :categorias
  has_many :historico_estoques
  has_many :itens_venda, foreign_key: 'estoque_de_produto_id'
  belongs_to :lote, optional: true
  audited associated_with: :informacao_loja
  has_associated_audits #:categorias, :historico_estoques, :itens_venda


  validates :nome_do_produto, presence: true
  validates :tipo_do_produto, presence: true
  validates :quantidade_em_estoque, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :preco_de_venda, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :informacao_loja_token, presence: true
  validates :codigo_barras, presence: true
  validates :codigo_interno, presence: true
  validates :ativo, inclusion: { in: [true, false] }
end