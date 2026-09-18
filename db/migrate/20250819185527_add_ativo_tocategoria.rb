class AddAtivoTocategoria < ActiveRecord::Migration[8.0]
  def change
    add_column :categorias, :ativo, :boolean, default: true, null: false unless column_exists?(:categorias, :ativo)
  end
end
