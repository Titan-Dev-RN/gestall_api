class Chandecolumnsidsfromvendas < ActiveRecord::Migration[8.0]
  def change
    add_column :vendas, :usuario_token_identificacao, :string
    add_column :vendas, :informacao_loja_token, :string
    
    remove_column :vendas, :usuario_id
    remove_column :vendas, :informacao_loja_id
    
    add_index :vendas, :usuario_token_identificacao
    add_index :vendas, :informacao_loja_token
  end
end
