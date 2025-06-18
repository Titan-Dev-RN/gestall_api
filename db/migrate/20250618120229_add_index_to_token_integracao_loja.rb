class AddIndexToTokenIntegracaoLoja < ActiveRecord::Migration[8.0]
  def change
    add_index :usuarios, :token_integracao_loja
  end
end
