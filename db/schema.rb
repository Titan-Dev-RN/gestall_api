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

ActiveRecord::Schema[8.0].define(version: 2025_04_06_025105) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "assinaturas", force: :cascade do |t|
    t.bigint "loja_id", null: false
    t.bigint "plano_id", null: false
    t.date "data_inicio"
    t.date "data_vencimento"
    t.string "status"
    t.string "gateway_pagamento"
    t.string "id_externo_gateway"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["loja_id"], name: "index_assinaturas_on_loja_id"
    t.index ["plano_id"], name: "index_assinaturas_on_plano_id"
  end

  create_table "compradors", force: :cascade do |t|
    t.bigint "loja_id", null: false
    t.string "nome"
    t.string "cpf"
    t.string "telefone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["loja_id"], name: "index_compradors_on_loja_id"
  end

  create_table "fornecedors", force: :cascade do |t|
    t.bigint "loja_id", null: false
    t.string "nome"
    t.string "cnpj"
    t.string "telefone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["loja_id"], name: "index_fornecedors_on_loja_id"
  end

  create_table "lojas", force: :cascade do |t|
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
    t.boolean "ativo"
    t.string "token_integracao"
    t.jsonb "configuracoes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "produto_estoques", force: :cascade do |t|
    t.bigint "loja_id", null: false
    t.string "nome_do_produto"
    t.string "categoria"
    t.integer "quantidade"
    t.decimal "preco_venda"
    t.decimal "preco_custo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["loja_id"], name: "index_produto_estoques_on_loja_id"
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
    t.index ["email"], name: "index_usuarios_on_email", unique: true
    t.index ["reset_password_token"], name: "index_usuarios_on_reset_password_token", unique: true
  end

  add_foreign_key "assinaturas", "lojas"
  add_foreign_key "assinaturas", "planos"
  add_foreign_key "compradors", "lojas"
  add_foreign_key "fornecedors", "lojas"
  add_foreign_key "produto_estoques", "lojas"
  add_foreign_key "transacao_pagamentos", "assinaturas"
  add_foreign_key "usuario_permissaos", "permissaos"
  add_foreign_key "usuario_permissaos", "usuarios"
end
