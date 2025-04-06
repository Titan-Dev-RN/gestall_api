class AddExtraFieldsToUsuarios < ActiveRecord::Migration[8.0]
  def change
    add_column :usuarios, :id_loja, :integer
    add_column :usuarios, :id_funcionario, :integer
    add_column :usuarios, :tipo_acesso, :string
    add_column :usuarios, :sign_in_count, :integer
    add_column :usuarios, :current_sign_in_at, :datetime
    add_column :usuarios, :last_sign_in_at, :datetime
    add_column :usuarios, :current_sign_in_ip, :string
    add_column :usuarios, :last_sign_in_ip, :string
    add_column :usuarios, :failed_attempts, :integer
    add_column :usuarios, :locked_at, :datetime
    add_column :usuarios, :unlock_token, :string
    add_column :usuarios, :ativo, :boolean, default: true
  end
end
