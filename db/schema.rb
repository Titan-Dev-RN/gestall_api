# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_04_17_113859) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "assinaturas", force: :cascade do |t|
    t.bigint "informacao_loja_id", null: false
    t.bigint "plano_id", null: false
    t.date "data_inicio"
    t.date "data_vencimento"
    t.string "status"
    t.string "gateway_pagamento"
    t.string "id_externo_gateway"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["informacao_loja_id"], name: "index_assinaturas_on_informacao_loja_id"
    t.index ["plano_id"], name: "index_assinaturas_on_plano_id"
  end

  create_table "clientes", force: :cascade do |t|
    t.bigint "informacao_loja_id", null: false
    t.string "nome"
    t.string "cpf_cnpj"
    t.string "telefone"
    t.string "email"
    t.text "endereco"
    t.datetime "data_cadastro"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["informacao_loja_id"], name: "index_clientes_on_informacao_loja_id"
  end

  create_table "estoque_de_produtos", force: :cascade do |t|
    t.bigint "informacao_loja_id", null: false
    t.string "nome_do_produto"
    t.string "categoria_do_produto"
    t.string "tipo_do_produto"
    t.integer "quantidade_em_estoque"
    t.integer "quantidade_minima"
    t.integer "quantidade_maxima"
    t.decimal "preco_de_venda"
    t.datetime "ultima_atualizacao"
    t.datetime "data_de_entrada"
    t.datetime "data_de_cadastro"
    t.string "codigo_barras"
    t.string "codigo_interno"
    t.string "unidade_medida"
    t.decimal "peso"
    t.string "marca"
    t.bigint "fornecedor_id", null: false
    t.boolean "ativo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fornecedor_id"], name: "index_estoque_de_produtos_on_fornecedor_id"
    t.index ["informacao_loja_id"], name: "index_estoque_de_produtos_on_informacao_loja_id"
  end

  create_table "fornecedors", force: :cascade do |t|
    t.bigint "informacao_loja_id", null: false
    t.string "nome"
    t.string "cnpj"
    t.string "contato"
    t.string "telefone"
    t.string "email"
    t.text "endereco"
    t.text "observacoes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["informacao_loja_id"], name: "index_fornecedors_on_informacao_loja_id"
  end

  create_table "funcionarios", force: :cascade do |t|
    t.bigint "informacao_loja_id", null: false
    t.bigint "usuario_id", null: false
    t.string "nome"
    t.string "cpf"
    t.string "rg"
    t.date "data_nascimento"
    t.string "cargo"
    t.decimal "salario_base"
    t.decimal "comissao_percentual"
    t.date "data_admissao"
    t.date "data_demissao"
    t.text "endereco"
    t.string "telefone"
    t.string "email"
    t.boolean "ativo"
    t.text "observacoes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["informacao_loja_id"], name: "index_funcionarios_on_informacao_loja_id"
    t.index ["usuario_id"], name: "index_funcionarios_on_usuario_id"
  end

  create_table "historico_estoques", force: :cascade do |t|
    t.bigint "estoque_de_produto_id", null: false
    t.bigint "informacao_loja_id", null: false
    t.bigint "usuario_id", null: false
    t.string "tipo_movimentacao"
    t.integer "quantidade"
    t.datetime "data_movimentacao"
    t.text "observacao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["estoque_de_produto_id"], name: "index_historico_estoques_on_estoque_de_produto_id"
    t.index ["informacao_loja_id"], name: "index_historico_estoques_on_informacao_loja_id"
    t.index ["usuario_id"], name: "index_historico_estoques_on_usuario_id"
  end

  create_table "informacao_lojas", force: :cascade do |t|
    t.string "nome_da_loja"
    t.string "nome_dono"
    t.string "forma_de_pagamento"
    t.string "endereco"
    t.string "cidade"
    t.string "estado"
    t.datetime "data_de_entrada"
    t.string "cnpj"
    t.string "telefone"
    t.string "email"
    t.string "plano_contratado"
    t.date "data_vencimento_plano"
    t.boolean "ativo", default: true
    t.string "token_integracao"
    t.jsonb "configuracoes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_vendas", force: :cascade do |t|
    t.bigint "venda_id", null: false
    t.bigint "estoque_de_produto_id", null: false
    t.integer "quantidade"
    t.decimal "valor_unitario"
    t.decimal "desconto"
    t.decimal "valor_total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["estoque_de_produto_id"], name: "index_item_vendas_on_estoque_de_produto_id"
    t.index ["venda_id"], name: "index_item_vendas_on_venda_id"
  end

  create_table "nota_fiscals", force: :cascade do |t|
    t.bigint "venda_id", null: false
    t.bigint "informacao_loja_id", null: false
    t.string "numero"
    t.string "serie"
    t.string "chave_acesso"
    t.datetime "data_emissao"
    t.text "xml"
    t.string "status"
    t.text "motivo_cancelamento"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["informacao_loja_id"], name: "index_nota_fiscals_on_informacao_loja_id"
    t.index ["venda_id"], name: "index_nota_fiscals_on_venda_id"
  end

  create_table "permissaos", force: :cascade do |t|
    t.string "nome"
    t.text "descricao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "planos", force: :cascade do |t|
    t.string "nome"
    t.text "descricao"
    t.decimal "valor_mensal"
    t.text "recursos"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transacao_pagamentos", force: :cascade do |t|
    t.bigint "assinatura_id", null: false
    t.decimal "valor"
    t.datetime "data_transacao"
    t.string "status"
    t.string "metodo_pagamento"
    t.string "codigo_transacao"
    t.text "descricao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assinatura_id"], name: "index_transacao_pagamentos_on_assinatura_id"
  end

  create_table "usuario_permissaos", force: :cascade do |t|
    t.bigint "usuario_id", null: false
    t.bigint "permissao_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permissao_id"], name: "index_usuario_permissaos_on_permissao_id"
    t.index ["usuario_id"], name: "index_usuario_permissaos_on_usuario_id"
  end

  create_table "usuarios", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nome"
    t.string "role"
    t.boolean "password_reset_required"
    t.integer "id_loja"
    t.integer "id_funcionario"
    t.string "tipo_acesso"
    t.integer "sign_in_count"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts"
    t.datetime "locked_at"
    t.string "unlock_token"
    t.boolean "ativo", default: true
    t.index ["email"], name: "index_usuarios_on_email", unique: true
    t.index ["reset_password_token"], name: "index_usuarios_on_reset_password_token", unique: true
  end

  create_table "vendas", force: :cascade do |t|
    t.bigint "informacao_loja_id", null: false
    t.bigint "cliente_id"
    t.datetime "data_venda"
    t.decimal "valor_total"
    t.decimal "desconto"
    t.string "status"
    t.string "forma_pagamento"
    t.bigint "usuario_id", null: false
    t.text "observacoes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_vendas_on_cliente_id"
    t.index ["informacao_loja_id"], name: "index_vendas_on_informacao_loja_id"
    t.index ["usuario_id"], name: "index_vendas_on_usuario_id"
  end

  add_foreign_key "assinaturas", "informacao_lojas"
  add_foreign_key "assinaturas", "planos"
  add_foreign_key "clientes", "informacao_lojas"
  add_foreign_key "estoque_de_produtos", "fornecedors"
  add_foreign_key "estoque_de_produtos", "informacao_lojas"
  add_foreign_key "fornecedors", "informacao_lojas"
  add_foreign_key "funcionarios", "informacao_lojas"
  add_foreign_key "funcionarios", "usuarios"
  add_foreign_key "historico_estoques", "estoque_de_produtos"
  add_foreign_key "historico_estoques", "informacao_lojas"
  add_foreign_key "historico_estoques", "usuarios"
  add_foreign_key "item_vendas", "estoque_de_produtos"
  add_foreign_key "item_vendas", "vendas"
  add_foreign_key "nota_fiscals", "informacao_lojas"
  add_foreign_key "nota_fiscals", "vendas"
  add_foreign_key "transacao_pagamentos", "assinaturas"
  add_foreign_key "usuario_permissaos", "permissaos"
  add_foreign_key "usuario_permissaos", "usuarios"
  add_foreign_key "vendas", "clientes"
  add_foreign_key "vendas", "informacao_lojas"
  add_foreign_key "vendas", "usuarios"
end
