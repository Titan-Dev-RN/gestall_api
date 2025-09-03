class Fixingloteseprodutos < ActiveRecord::Migration[8.0]
  def change
    remove_column :lotes, :estoque_de_produto_id
    remove_column :estoque_de_produtos, :lote_id

    add_reference :estoque_de_produtos, :lote, null: true, foreign_key: true
  end
end
