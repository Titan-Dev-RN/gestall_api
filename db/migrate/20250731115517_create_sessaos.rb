class CreateSessaos < ActiveRecord::Migration[8.0]
  def change
    create_table :sessaos do |t|
      t.string :usuario_token_identificacao
      t.string :informacao_loja_token
      t.datetime :inicio
      t.datetime :fim
      t.timestamps
    end
  end
end
