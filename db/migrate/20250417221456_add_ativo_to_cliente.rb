class AddAtivoToCliente < ActiveRecord::Migration[8.0]
  def change
    add_column :clientes, :ativo, :boolean, default: true
  end
end
