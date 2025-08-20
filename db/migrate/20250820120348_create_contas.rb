class CreateContas < ActiveRecord::Migration[8.0]
  def change
    create_table :contas do |t|
      t.string :descricao
      t.string :destinatario
      t.string :tipo
      t.decimal :valor, precision: 10, scale: 2
      t.references :categorias, foreign_key: true
      t.date :vencimento
      t.string :status
      t.string :observacao
      t.timestamps
    end
  end
end
