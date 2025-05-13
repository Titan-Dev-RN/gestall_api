Claro! Aqui está um modelo de `README.md` para o seu projeto Rails com Devise, pronto para ser clonado e configurado em outra máquina:

---

```markdown
# Sistema de Autenticação com Devise

Este projeto é uma aplicação Ruby on Rails com sistema de autenticação usando Devise. O objetivo é permitir o cadastro de usuários com diferentes níveis de acesso, utilizando criptografia e suporte a redefinição de senha.

## 🔧 Requisitos

- Ruby 3.3.0
- Rails 8.x
- PostgreSQL
- Node.js e Yarn
- Git

## ⚙️ Instalação e Configuração

1. **Clone o projeto:**

```bash
git clone https://github.com/seu-usuario/seu-repositorio.git
cd seu-repositorio
```

2. **Instale as dependências:**

```bash
bundle install
```

- caso não der certo tente:
```bash
sudo apt install -y libpq-dev
bundle install
yarn install
```

3. **Configure o banco de dados:**

```bash
rails db:setup
# ou separadamente:
# rails db:create
# rails db:migrate
# rails db:seed (se houver seeds)
```

4. **Configure as credenciais:**

Gere sua chave com 
```bash
rails secret
```

Crie e Adicione no .env nas variaveis:

```yaml
JWT_KEY=
JWT_SECRET=
JWT_SECRET_KEY=
```

5. **Inicie o servidor:**

```bash
rails server
```

Acesse a aplicação em [http://localhost:3000](http://localhost:3000)

---

## Resumo de estrutura do BD
```bash
bundle exec rails runner lib/uml.rb > estrutura.txt
```

## 📬 Criar um usuário admin via API (Insomnia ou similar)

**Endpoint:**

```
POST /usuarios
```

**Body (JSON):**

```json
{
  "usuario": {
    "nome": "Administrador",
    "email": "admin@email.com",
    "password": "senha123",
    "password_confirmation": "senha123",
    "role": "admin"
  }
}
```

> Certifique-se de que a rota e o controller `UsuariosController` estão configurados para aceitar este tipo de request.

---

## ✉️ Login

**Endpoint:**

```
POST /login
```

**Body (JSON):**

```json
{
  "usuario": {
    "email": "admin@loja.com",
    "password": "senha123"
  }
}
```

## ✉️ produtos 

**Endpoint:**
LISTAR
```
GET /api/v1/produtos/
```
DESATIVAR
```
DELETE /api/v1/produtos/1
```
REGISTAR
```
POST /api/v1/produtos
```
```json
{
    "produto": {
      "nome_do_produto": "Lightweight Bronze Wallet",
      "categoria_do_produto": "Esportes",
      "tipo_do_produto": "Unidade",
      "quantidade_em_estoque": 87,
      "quantidade_minima": 5,
      "quantidade_maxima": 150,
      "preco_de_venda": 118.89,
      "codigo_barras": "8205913537519",
      "codigo_interno": "PROD1000",
      "unidade_medida": "LT",
      "peso": 8.0,
      "marca": "Monteiro-Ribeira",
      "fornecedor_id": 3,
      "ativo": true
    }
}
```
ATUALIZAR
```
PUT /api/v1/produtos/1
```
```json
{
    "produto": {
      "nome_do_produto": "Incredible Linen Car (Updated)",
      "categoria_do_produto": "Automóveis",
      "quantidade_em_estoque": 30,
      "preco_de_venda": 19.99,
      "marca": "da Rosa & Cia Ltda",
      "ativo": false
    }
}
```

## ✉️ Vendas 

**Endpoint:**
LISTAR
```
GET /api/v1/vendas/vendas_all
```
INICIAR
```
POST /api/v1/vendas
```
ADICIONAR ITEM
```
POST /api/v1/vendas/id/adicionar_item
```
```json
{
  "codigo_barras": "6460724085297",
	"quantidade": 1,
	"desconto": 10
}
```
REMOVER ITEM
```
DELETE /api/v1/vendas/id/remover_item/id_item
```

FINALIZAR VENDA
```
POST /api/v1/vendas/id/finalizar
```

CANCELAR VENDA
```
POST /api/v1/vendas/8/cancelar
```

**Header (JSON):**
AUTH
Bearer token

---

## ✉️ Fornecedores

**Endpoint:**
REATIVAR FORNECEDOR
```
POST /api/v1/fornecedores/1/reativar_fornecedor
```

LISTAR
```
GET /api/v1/fornecedores/:id
```
```
GET /api/v1/fornecedores
```

ATUALIZAR
```
PUT /api/v1/fornecedores/:id
```
```json
{
  "fornecedor": {
    "nome": "Distribuidora Central",
    "cnpj": "12.345.678/0001-90",
    "contato": "João Silva",
    "telefone": "(11) 91234-5678",
    "email": "contato@distribuidoracentral.com.br",
    "endereco": "Rua das Flores, 123 - São Paulo - SP",
    "observacoes": "Entrega rápida e bons preços"
  }
}
```

CRIAR FORNECEDOR
```
POST /api/v1/fornecedores
```
```json
{
  "fornecedor": {
    "nome": "Distribuidora Central da baixa d aegua",
    "cnpj": "12.345.678/0001-90",
    "contato": "João Silva",
    "telefone": "(11) 91234-5678",
    "email": "contato@distribuidoracentral.com.br",
    "endereco": "Rua das Flores, 123 - São Paulo - SP",
    "observacoes": "Entrega rápida e bons preços"
  }
}
```

REMOVER FORNECEDOR
```
DELETE /api/v1/fornecedores/:id
```

**Header (JSON):**
AUTH
Bearer token

---
