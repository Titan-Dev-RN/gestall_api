class RemoveInformacaoLojaIdFromTables < ActiveRecord::Migration[8.0]
  def change
    remove_column :estoque_de_produtos, :informacao_loja_id
    remove_column :fornecedors, :informacao_loja_id
    remove_column :funcionarios, :informacao_loja_id
    remove_column :historico_estoques, :informacao_loja_id
  end
end
