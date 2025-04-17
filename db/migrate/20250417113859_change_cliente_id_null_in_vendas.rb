class ChangeClienteIdNullInVendas < ActiveRecord::Migration[8.0]
  def change
    change_column_null :vendas, :cliente_id, true
  end
end
