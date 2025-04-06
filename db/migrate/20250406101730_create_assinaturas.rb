class CreateAssinaturas < ActiveRecord::Migration[8.0]
  def change
    create_table :assinaturas do |t|
      t.references :informacao_loja, null: false, foreign_key: true
      t.references :plano, null: false, foreign_key: true
      t.date :data_inicio
      t.date :data_vencimento
      t.string :status
      t.string :gateway_pagamento
      t.string :id_externo_gateway

      t.timestamps
    end
  end
end
