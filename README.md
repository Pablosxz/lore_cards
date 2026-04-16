# Lore Cards

Plataforma para gerenciamento de cards de itens e monstros de RPG de mesa.

## Pré-requisitos

- [Ruby](https://www.ruby-lang.org/) 3.4.4
- [Rails](https://rubyonrails.org/) 7.2
- [PostgreSQL](https://www.postgresql.org/) 14+
- [Bundler](https://bundler.io/)

## Configuração

### 1. Clone o repositório

```bash
git clone <url-do-repositório>
cd lore_cards
```

### 2. Instale as dependências

```bash
bundle install
```

### 3. Configure o banco de dados

Crie um arquivo `config/database.yml` com suas credenciais do PostgreSQL, ou copie o exemplo:

```bash
cp config/database.yml.example config/database.yml
```

Edite com seu usuário e senha do PostgreSQL:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: seu_usuario
  password: sua_senha
  host: localhost

development:
  <<: *default
  database: lore_cards_development

test:
  <<: *default
  database: lore_cards_test
```

### 4. Crie e migre o banco de dados

```bash
bin/rails db:create db:migrate
```

## Rodando o projeto

O projeto usa Rails + Tailwind CSS em modo watch. Use o comando abaixo para iniciar os dois processos juntos:

```bash
bin/dev
```

Ou separadamente:

```bash
# Servidor Rails
bin/rails server

# Compilador Tailwind em modo watch
bin/rails tailwindcss:watch
```

Acesse em: **http://localhost:3000**

## Tecnologias

| Tecnologia | Uso |
|---|---|
| Ruby on Rails 7.2 | Framework principal |
| PostgreSQL | Banco de dados |
| Tailwind CSS 3 | Estilização |
| Devise | Autenticação |
| Hotwire (Turbo + Stimulus) | Interatividade |
| shadcn/ui (Rails port) | Componentes de UI |

## Componentes de UI

Os componentes shadcn ficam em:

- `app/helpers/components/` — helpers (`render_card`, `render_input`, `render_label`, `render_button`)
- `app/views/components/ui/` — partials dos componentes

## Testes

```bash
bin/rails test
```
