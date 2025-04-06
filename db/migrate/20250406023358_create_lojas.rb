class CreateLojas < ActiveRecord::Migration[8.0]
  def change
    create_table :lojas do |t|
      t.string :nome_da_loja
      t.string :nome_dono
      t.string :forma_de_pagamento
      t.string :endereco
      t.string :cidade
      t.string :estado
      t.datetime :data_de_entrada
      t.string :cnpj
      t.string :telefone
      t.string :email
      t.string :plano_contratado
      t.date :data_vencimento_plano
      t.boolean :ativo
      t.string :token_integracao
      t.jsonb :configuracoes

      t.timestamps
    end
  end
end
