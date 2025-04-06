class AddFieldsToUsuarios < ActiveRecord::Migration[8.0]
  def change
    add_column :usuarios, :nome, :string
    add_column :usuarios, :role, :string
    add_column :usuarios, :password_reset_required, :boolean
  end
end
