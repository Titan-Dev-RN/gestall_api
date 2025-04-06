class CreateVendas < ActiveRecord::Migration[8.0]
  def change
    create_table :vendas do |t|
      t.references :informacao_loja, null: false, foreign_key: true
      t.references :cliente, null: false, foreign_key: true
      t.datetime :data_venda
      t.decimal :valor_total
      t.decimal :desconto
      t.string :status
      t.string :forma_pagamento
      t.references :usuario, null: false, foreign_key: true
      t.text :observacoes

      t.timestamps
    end
  end
end
