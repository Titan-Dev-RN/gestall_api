class CreateCompradors < ActiveRecord::Migration[8.0]
  def change
    create_table :compradors do |t|
      t.references :loja, null: false, foreign_key: true
      t.string :nome
      t.string :cpf
      t.string :telefone
      t.string :email

      t.timestamps
    end
  end
end
