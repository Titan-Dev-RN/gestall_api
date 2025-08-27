class AddStatusToFuncionarios < ActiveRecord::Migration[8.0]
  def change
    add_column :funcionarios, :status, :string
    add_column :funcionarios, :data_desativacao, :date
  end
end
