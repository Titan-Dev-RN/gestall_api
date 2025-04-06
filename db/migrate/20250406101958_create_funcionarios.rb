class CreateFuncionarios < ActiveRecord::Migration[8.0]
  def change
    create_table :funcionarios do |t|
      t.references :informacao_loja, null: false, foreign_key: true
      t.references :usuario, null: false, foreign_key: true
      t.string :nome
      t.string :cpf
      t.string :rg
      t.date :data_nascimento
      t.string :cargo
      t.decimal :salario_base
      t.decimal :comissao_percentual
      t.date :data_admissao
      t.date :data_demissao
      t.text :endereco
      t.string :telefone
      t.string :email
      t.boolean :ativo
      t.text :observacoes

      t.timestamps
    end
  end
end
