class AddCepInscricaoEstadual < ActiveRecord::Migration[8.0]
  def change
    add_column :informacao_lojas, :cep, :string, null: true
    add_column :informacao_lojas, :inscricao_estadual, :string, null: true
  end
end
