class ChangeFornecedorIdToOptionalInEstoqueDeProdutos < ActiveRecord::Migration[8.0]
  def change
    change_column_null :estoque_de_produtos, :fornecedor_id, true
  end
end
