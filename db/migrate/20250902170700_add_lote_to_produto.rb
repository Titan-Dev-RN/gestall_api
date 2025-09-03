class AddLoteToProduto < ActiveRecord::Migration[8.0]
  def change
    add_column :estoque_de_produtos, :lote_id, :integer, null: true
  end
end
