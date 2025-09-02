class CreateLotes < ActiveRecord::Migration[8.0]
  def change
    create_table :lotes do |t|
      t.string :nome
      t.date :validade
      t.date :data_entrada
      t.references :estoque_de_produto, null: true, foreign_key: true
      t.timestamps
    end
  end
end
