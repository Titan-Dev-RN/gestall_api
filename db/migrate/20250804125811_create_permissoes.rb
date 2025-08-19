class CreatePermissoes < ActiveRecord::Migration[8.0]
  def change
    create_table :permissoes, id: false do |t|
      t.string :token, primary_key: true
      t.string :token_integracao_loja
      t.string :nome
      t.text :descricao
      t.timestamps
    end

    add_index :permissoes, [:token_integracao_loja, :nome], unique: true
  end
end