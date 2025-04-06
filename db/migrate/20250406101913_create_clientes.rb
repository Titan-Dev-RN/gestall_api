class CreateClientes < ActiveRecord::Migration[8.0]
  def change
    create_table :clientes do |t|
      t.references :informacao_loja, null: false, foreign_key: true
      t.string :nome
      t.string :cpf_cnpj
      t.string :telefone
      t.string :email
      t.text :endereco
      t.datetime :data_cadastro

      t.timestamps
    end
  end
end
