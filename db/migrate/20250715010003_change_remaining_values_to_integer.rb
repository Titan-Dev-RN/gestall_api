class ChangeRemainingValuesToInteger < ActiveRecord::Migration[8.0]
  def change
    change_column :funcionarios, :salario_base, :integer
    change_column :funcionarios, :comissao_percentual, :integer
  end
end
