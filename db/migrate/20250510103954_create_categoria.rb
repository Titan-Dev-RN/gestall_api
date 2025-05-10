class CreateCategoria < ActiveRecord::Migration[8.0]
  def change
    create_table :categorias do |t|
      t.string :nome, null: false
      t.timestamps
    end
  end
end
