class AddTokenIdentificacaoToUsuarios < ActiveRecord::Migration[8.0]
  def change
    add_column :usuarios, :token_identificacao, :string, null: false
    add_index :usuarios, :token_identificacao, unique: true
  end
end
