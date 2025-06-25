class Removerconfigdeinfoloja < ActiveRecord::Migration[8.0]
  def change
    remove_column :informacao_lojas, :configuracoes, :jsonb
  end
end
