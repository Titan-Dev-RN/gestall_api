class Fixforeginkeyfuncionario < ActiveRecord::Migration[8.0]
  def up
    # 1. Remove a foreign key constraint existente se ela existir
    if foreign_key_exists?(:funcionarios, :usuarios, column: :usuario_token_identificacao)
      remove_foreign_key :funcionarios, column: :usuario_token_identificacao
    end

    # 2. Remove o índice existente se ele existir
    if index_exists?(:funcionarios, :usuario_token_identificacao)
      remove_index :funcionarios, :usuario_token_identificacao
    end

    # 3. Altera a coluna para string (que vai referenciar usuarios.token_identificacao)
    change_column :funcionarios, :usuario_token_identificacao, :string

    # 4. Adiciona a nova foreign key correta
    add_foreign_key :funcionarios, :usuarios, 
      column: :usuario_token_identificacao,
      primary_key: :token_identificacao,
      name: 'fk_funcionarios_usuarios_on_token_identificacao'

    # 5. Adiciona o novo índice
    add_index :funcionarios, :usuario_token_identificacao
  end

  def down
    # Para rollback, revertemos todas as alterações
    remove_foreign_key :funcionarios, column: :usuario_token_identificacao
    remove_index :funcionarios, :usuario_token_identificacao
    change_column :funcionarios, :usuario_token_identificacao, :uuid
    add_index :funcionarios, :usuario_token_identificacao
  end
end