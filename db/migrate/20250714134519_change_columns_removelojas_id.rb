class ChangeColumnsRemovelojasId < ActiveRecord::Migration[8.0]
  def change
    remove_column :clientes, :informacao_loja_id
    add_column :clientes, :informacao_loja_token, :string
    add_index :clientes, :informacao_loja_token
  end
end
