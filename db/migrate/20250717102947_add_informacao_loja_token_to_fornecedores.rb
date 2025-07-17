class AddInformacaoLojaTokenToFornecedores < ActiveRecord::Migration[8.0]
  def change
    add_column :fornecedors, :informacao_loja_token, :string
    add_index :fornecedors, :informacao_loja_token
  end
end
