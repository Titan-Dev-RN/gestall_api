class CreateProdutoEstoques < ActiveRecord::Migration[8.0]
  def change
    create_table :produto_estoques do |t|
      t.references :loja, null: false, foreign_key: true
      t.string :nome_do_produto
      t.string :categoria
      t.integer :quantidade
      t.decimal :preco_venda
      t.decimal :preco_custo

      t.timestamps
    end
  end
end
