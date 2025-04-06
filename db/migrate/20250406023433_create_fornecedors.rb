class CreateFornecedors < ActiveRecord::Migration[8.0]
  def change
    create_table :fornecedors do |t|
      t.references :loja, null: false, foreign_key: true
      t.string :nome
      t.string :cnpj
      t.string :telefone
      t.string :email

      t.timestamps
    end
  end
end
