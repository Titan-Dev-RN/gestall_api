class CreateServicos < ActiveRecord::Migration[8.0]
  def change
    remove_index :funcionarios, :usuario_token_identificacao if index_exists?(:funcionarios, :usuario_token_identificacao)

    # Adicionar o índice único
    add_index :funcionarios, :usuario_token_identificacao, unique: true

    create_table :servicos do |t|
      t.string :nome
      t.text :descricao
      t.integer :valor
      t.references :categoria, foreign_key: { to_table: :categorias }
      t.string :token_integracao_loja
      t.string :usuario_token_identificacao
      t.boolean :status, default: true
      t.timestamps

      # Adicionar índices para melhor performance
      t.index :token_integracao_loja
      t.index :usuario_token_identificacao
    end

    add_foreign_key :servicos, :informacao_lojas, 
                   column: :token_integracao_loja, 
                   primary_key: :token_integracao

    add_foreign_key :servicos, :funcionarios, 
                   column: :usuario_token_identificacao, 
                   primary_key: :usuario_token_identificacao
  end
end