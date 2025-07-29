class ChangeFuncionarioIDforTokenUser < ActiveRecord::Migration[8.0]
  def change
    rename_column :funcionarios, :usuario_id, :usuario_token_identificacao
    change_column :funcionarios, :usuario_token_identificacao, :uuid

    add_index :funcionarios, :usuario_token_identificacao
  end
end
