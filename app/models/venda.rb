class Venda < ApplicationRecord
  belongs_to :informacao_loja
  belongs_to :cliente, :optional => true
  belongs_to :usuario
  
  has_many :itens_venda, :class_name => 'ItemVenda', foreign_key: 'venda_id'
  has_many :estoque_de_produtos, through: :itens_venda
  has_one :nota_fiscal

  audited associated_with: :informacao_loja
  has_associated_audits #:itens_venda, :estoque_de_produtos, :nota_fiscal


end