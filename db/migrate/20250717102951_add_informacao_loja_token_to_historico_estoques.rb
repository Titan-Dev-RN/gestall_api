class AddInformacaoLojaTokenToHistoricoEstoques < ActiveRecord::Migration[8.0]
  def change
    add_column :historico_estoques, :informacao_loja_token, :string
    add_index :historico_estoques, :informacao_loja_token
  end
end
