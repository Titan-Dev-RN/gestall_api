class AddDuracaoToServico < ActiveRecord::Migration[8.0]
  def change
    add_column :servicos, :duracao, :string
    add_column :servicos, :funcionario_id, :bigint
    add_index :servicos, :funcionario_id
  end
end
