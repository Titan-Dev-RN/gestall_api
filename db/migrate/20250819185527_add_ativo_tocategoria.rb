class AddAtivoTocategoria < ActiveRecord::Migration[8.0]
  def change
    add_column :categorias, :ativo, :boolean, default: true, null: false
  end
end
