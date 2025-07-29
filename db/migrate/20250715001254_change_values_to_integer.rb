class ChangeValuesToInteger < ActiveRecord::Migration[8.0]
  def change
    change_column :estoque_de_produtos, :preco_de_venda, :integer

    change_column :item_vendas, :valor_unitario, :integer
    change_column :item_vendas, :desconto, :integer
    change_column :item_vendas, :valor_total, :integer

    change_column :planos, :valor_mensal, :integer

    change_column :transacao_pagamentos, :valor, :integer

    change_column :vendas, :valor_total, :integer
    change_column :vendas, :desconto, :integer
  end
end
