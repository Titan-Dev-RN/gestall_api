class CreateHistoricoEstoques < ActiveRecord::Migration[8.0]
  def change
    create_table :historico_estoques do |t|
      t.references :estoque_de_produto, null: false, foreign_key: true
      t.references :informacao_loja, null: false, foreign_key: true
      t.references :usuario, null: false, foreign_key: true
      t.string :tipo_movimentacao
      t.integer :quantidade
      t.datetime :data_movimentacao
      t.text :observacao

      t.timestamps
    end
  end
end
