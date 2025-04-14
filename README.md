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
yarn install
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

4. **(Opcional) Configure as credenciais:**

Se estiver utilizando `Rails credentials`:

```bash
EDITOR="code --wait" rails credentials:edit
```

Adicione, por exemplo:

```yaml
devise:
  jwt_secret_key: sua_chave_super_secreta
```

5. **Inicie o servidor:**

```bash
rails server
```

Acesse a aplicação em [http://localhost:3000](http://localhost:3000)

---

## 📬 Criar um usuário admin via API (Postman ou similar)

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
POST /usuarios/sign_in
```

**Body (JSON):**

```json
{
  "usuario": {
    "email": "admin@email.com",
    "password": "senha123"
  }
}
```

---

## 🛠 Ferramentas utilizadas

- [Ruby on Rails](https://rubyonrails.org/)
- [Devise](https://github.com/heartcombo/devise)
- [BCrypt](https://github.com/codahale/bcrypt-ruby)
- [Postman](https://www.postman.com/) (para testes de API)

---

## 🔐 Níveis de Acesso

O sistema diferencia usuários com base no atributo `role`, que pode ser:

- `admin`
- `gestor de RH`

---

## 🗂 Organização do Projeto

- `app/models/usuario.rb` – Modelo principal do Devise com atributos adicionais
- `app/controllers/usuarios_controller.rb` – Controller para criação de usuários
- `config/routes.rb` – Rotas customizadas com Devise

---