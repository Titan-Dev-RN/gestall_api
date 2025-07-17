class AddInformacaoLojaTokenToFuncionarios < ActiveRecord::Migration[8.0]
  def change
    add_column :funcionarios, :informacao_loja_token, :string
    add_index :funcionarios, :informacao_loja_token
  end
end
