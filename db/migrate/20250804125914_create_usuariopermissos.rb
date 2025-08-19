class CreateUsuariopermissos < ActiveRecord::Migration[8.0]
  def change
    create_table :usuarios_permissoes, id: false do |t|
      t.string :usuario_token_identificacao
      t.string :permissao_token
      t.string :token_integracao_loja
      t.timestamps
    end

    add_index :usuarios_permissoes, 
              [:usuario_token_identificacao, :permissao_token, :token_integracao_loja], 
              unique: true,
              name: 'index_usuarios_permissoes_on_tokens'
  end
end