class CreateNotaFiscals < ActiveRecord::Migration[8.0]
  def change
    create_table :nota_fiscals do |t|
      t.references :venda, null: false, foreign_key: true
      t.references :informacao_loja, null: false, foreign_key: true
      t.string :numero
      t.string :serie
      t.string :chave_acesso
      t.datetime :data_emissao
      t.text :xml
      t.string :status
      t.text :motivo_cancelamento

      t.timestamps
    end
  end
end
