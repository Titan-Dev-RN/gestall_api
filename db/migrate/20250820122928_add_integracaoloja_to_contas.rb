class AddIntegracaolojaToContas < ActiveRecord::Migration[8.0]
  def change
    add_column :contas, :token_integracao_loja, :string unless column_exists?(:contas, :token_integracao_loja)
    add_index :contas, :token_integracao_loja unless index_exists?(:contas, :token_integracao_loja)
    add_index :informacao_lojas, :token_integracao, unique: true unless index_exists?(:informacao_lojas, :token_integracao)
    add_foreign_key :contas, :informacao_lojas, column: :token_integracao_loja, primary_key: :token_integracao unless foreign_key_exists?(:contas, :informacao_lojas, column: :token_integracao_loja)
  end
end
