class Addsessaotovendas < ActiveRecord::Migration[8.0]
  def change
    add_reference :vendas, :sessao, foreign_key: true, type: :integer
  end
end
