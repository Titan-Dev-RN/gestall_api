class AddIntegracaolojaToContas < ActiveRecord::Migration[8.0]
  def change
    add_column :contas, :token_integracao_loja, :string
    add_index :contas, :token_integracao_loja
    add_index :informacao_lojas, :token_integracao, unique: true # Ensure uniqueness
    add_foreign_key :contas, :informacao_lojas, column: :token_integracao_loja, primary_key: :token_integracao
  end
end
