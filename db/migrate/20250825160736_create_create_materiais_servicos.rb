class CreateCreateMateriaisServicos < ActiveRecord::Migration[8.0]
  def change
    create_table :materiais_servico do |t|
      t.references :servico, foreign_key: true
      t.references :estoque_de_produto, foreign_key: true
      t.integer :quantidade_utilizada
      t.decimal :custo_unitario
      t.timestamps
    end
  end
end