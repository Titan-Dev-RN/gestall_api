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

anexe suas informações de banco de dados suas credenciais do banco de dados conforme exemplo:

- exemplo de versão final (também disponível no [example.env](example.env))
```yaml
JWT_KEY=###################...
JWT_SECRET=################...
JWT_SECRET_KEY=############...
GESTALL_DB_NAME=postgres
GESTALL_DB_USERNAME=gabriel
GESTALL_DB_PASSWORD=0000
GESTALL_DB_HOST=localhost
GESTALL_DB_PORT=5432
```

5. **Inicie o servidor:**

```bash
rails server
```

Acesse a aplicação em [http://localhost:3000](http://localhost:3000)

---

## Resumo de estrutura do BD
```bash
bundle exec rake db:dump_schema
```

## Comandos De task de migration e backup

```bash
rails tenants:migrate
```

```bash
rails backup:all
```

---

**Header (JSON):**
AUTH
Bearer token

---
