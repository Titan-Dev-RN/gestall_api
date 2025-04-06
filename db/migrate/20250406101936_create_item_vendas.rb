class CreateItemVendas < ActiveRecord::Migration[8.0]
  def change
    create_table :item_vendas do |t|
      t.references :venda, null: false, foreign_key: true
      t.references :estoque_de_produto, null: false, foreign_key: true
      t.integer :quantidade
      t.decimal :valor_unitario
      t.decimal :desconto
      t.decimal :valor_total

      t.timestamps
    end
  end
end
