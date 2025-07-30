class DropPermissoes < ActiveRecord::Migration[8.0]
  def change
    drop_table :usuario_permissaos
    drop_table :permissaos
  end
end
