class CreateUsuarioPermissaos < ActiveRecord::Migration[8.0]
  def change
    create_table :usuario_permissaos do |t|
      t.references :usuario, null: false, foreign_key: true
      t.references :permissao, null: false, foreign_key: true

      t.timestamps
    end
  end
end
