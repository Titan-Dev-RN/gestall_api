class AddStatusCodeToLote < ActiveRecord::Migration[8.0]
  def change
    add_column :lotes, :status, :string
    add_column :lotes, :codigo, :string
  end
end
