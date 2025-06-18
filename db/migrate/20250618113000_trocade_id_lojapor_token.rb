class TrocadeIdLojaporToken < ActiveRecord::Migration[8.0]
  def up
    # 1. Primeiro, remover todas as constraints de chave estrangeira
    remove_foreign_key :funcionarios, :usuarios
    remove_foreign_key :historico_estoques, :usuarios
    remove_foreign_key :usuario_permissaos, :usuarios
    remove_foreign_key :vendas, :usuarios

    # 2. Adicionar a nova coluna token_integracao_loja
    add_column :usuarios, :token_integracao_loja, :string

    # 3. Adicionar a coluna uuid temporária
    add_column :usuarios, :uuid, :uuid, default: 'gen_random_uuid()', null: false

    # 4. Atualizar todas as referências nas outras tabelas
    [
      :funcionarios,
      :historico_estoques,
      :usuario_permissaos,
      :vendas
    ].each do |table|
      add_column table, :usuario_uuid, :uuid
      execute "UPDATE #{table} SET usuario_uuid = usuarios.uuid FROM usuarios WHERE #{table}.usuario_id = usuarios.id"
      remove_column table, :usuario_id
      rename_column table, :usuario_uuid, :usuario_id
    end

    # 5. Remover a coluna id original e renomear uuid para id
    remove_column :usuarios, :id
    rename_column :usuarios, :uuid, :id
    execute "ALTER TABLE usuarios ADD PRIMARY KEY (id);"

    # 6. Remover a coluna id_loja
    remove_column :usuarios, :id_loja

    # 7. Recriar as constraints de chave estrangeira
    add_foreign_key :funcionarios, :usuarios
    add_foreign_key :historico_estoques, :usuarios
    add_foreign_key :usuario_permissaos, :usuarios
    add_foreign_key :vendas, :usuarios
  end

  def down
    # Implementação do rollback seria complexa e não recomendada neste caso
    raise ActiveRecord::IrreversibleMigration
  end
end
