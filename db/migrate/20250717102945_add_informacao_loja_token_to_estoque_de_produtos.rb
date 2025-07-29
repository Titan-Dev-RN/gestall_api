class AddInformacaoLojaTokenToEstoqueDeProdutos < ActiveRecord::Migration[8.0]
  def change
    add_column :estoque_de_produtos, :informacao_loja_token, :string
    add_index :estoque_de_produtos, :informacao_loja_token
  end
end
