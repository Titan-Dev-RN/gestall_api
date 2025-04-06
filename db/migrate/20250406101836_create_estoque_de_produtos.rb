class CreateEstoqueDeProdutos < ActiveRecord::Migration[8.0]
  def change
    create_table :estoque_de_produtos do |t|
      t.references :informacao_loja, null: false, foreign_key: true
      t.string :nome_do_produto
      t.string :categoria_do_produto
      t.string :tipo_do_produto
      t.integer :quantidade_em_estoque
      t.integer :quantidade_minima
      t.integer :quantidade_maxima
      t.decimal :preco_de_venda
      t.datetime :ultima_atualizacao
      t.datetime :data_de_entrada
      t.datetime :data_de_cadastro
      t.string :codigo_barras
      t.string :codigo_interno
      t.string :unidade_medida
      t.decimal :peso
      t.string :marca
      t.references :fornecedor, null: false, foreign_key: true
      t.boolean :ativo

      t.timestamps
    end
  end
end
