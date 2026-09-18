class AddStatusToFuncionarios < ActiveRecord::Migration[8.0]
  def change
    add_column :funcionarios, :status, :string unless column_exists?(:funcionarios, :status)
    add_column :funcionarios, :data_desativacao, :date unless column_exists?(:funcionarios, :data_desativacao)
  end
end
