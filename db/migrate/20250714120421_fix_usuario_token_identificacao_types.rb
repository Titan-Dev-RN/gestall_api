class FixUsuarioTokenIdentificacaoTypes < ActiveRecord::Migration[8.0]
  def up
    if foreign_key_exists?(:historico_estoques, :usuarios, name: 'fk_rails_5bef26065b')
      remove_foreign_key :historico_estoques, name: 'fk_rails_5bef26065b'
    elsif foreign_key_exists?(:historico_estoques, :usuarios, column: :usuario_token_identificacao)
      remove_foreign_key :historico_estoques, column: :usuario_token_identificacao
    end

    change_column :historico_estoques, :usuario_token_identificacao, :string

    add_foreign_key :historico_estoques, :usuarios,
      column: :usuario_token_identificacao,
      primary_key: :token_identificacao,
      on_delete: :nullify
  end

  def down
    remove_foreign_key :historico_estoques, column: :usuario_token_identificacao

    change_column :historico_estoques, :usuario_token_identificacao, :uuid
  end
end