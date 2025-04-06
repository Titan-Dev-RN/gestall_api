class CreatePlanos < ActiveRecord::Migration[8.0]
  def change
    create_table :planos do |t|
      t.string :nome
      t.text :descricao
      t.decimal :valor_mensal
      t.text :recursos

      t.timestamps
    end
  end
end
