class ChangeUsuarioIdToTokenIdentificacaoInHistoricoEstoque < ActiveRecord::Migration[8.0]
  def change
    rename_column :historico_estoques, :usuario_id, :usuario_token_identificacao
    change_column :historico_estoques, :usuario_token_identificacao, :uuid

    add_index :historico_estoques, :usuario_token_identificacao
  end
end
