class CreateMateriaisServicos < ActiveRecord::Migration[8.0]
  def change
    create_table :materiais_servico, if_not_exists: true do |t|
      t.references :servico, foreign_key: true
      t.references :estoque_de_produto, foreign_key: true
      t.integer :quantidade_utilizada
      t.decimal :custo_unitario
      t.timestamps
    end
  end
end