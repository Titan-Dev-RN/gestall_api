class ItemVenda < ApplicationRecord
  belongs_to :venda
  belongs_to :estoque_de_produto
end
