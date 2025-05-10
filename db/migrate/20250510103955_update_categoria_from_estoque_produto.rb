class UpdateCategoriaFromEstoqueProduto < ActiveRecord::Migration[8.0]
  def change
    remove_column :estoque_de_produtos, :categoria_do_produto
    add_column :estoque_de_produtos, :categoria_do_produto, :bigint
    add_foreign_key :estoque_de_produtos, :categorias, column: :categoria_do_produto
  end
end
