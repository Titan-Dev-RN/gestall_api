class CreateTransacaoPagamentos < ActiveRecord::Migration[8.0]
  def change
    create_table :transacao_pagamentos do |t|
      t.references :assinatura, null: false, foreign_key: true
      t.decimal :valor
      t.datetime :data_transacao
      t.string :status
      t.string :metodo_pagamento
      t.string :codigo_transacao
      t.text :descricao

      t.timestamps
    end
  end
end
