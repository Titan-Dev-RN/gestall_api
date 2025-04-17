class AddStatusToFornecedores < ActiveRecord::Migration[8.0]
  def change
    add_column :fornecedors, :ativo, :boolean, default: true
  end
end
