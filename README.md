# Cupcakes Gourmet: loja virtual

Projeto Integrador Transdisciplinar em Engenharia de Software II (Cruzeiro do Sul Virtual).
Implementação da especificação ágil do PIT I (22 histórias de usuário) como aplicação **web responsiva** em **Ruby on Rails (MVC)**.

| Item | Escolha |
|---|---|
| Linguagem do back-end | Ruby 3.3 · Ruby on Rails 8.1 (padrão MVC) |
| Front-end | HTML (ERB), CSS próprio mobile-first, JavaScript (Turbo/Stimulus) |
| Banco de dados | SQLite (desenvolvimento e testes) · PostgreSQL (produção) |
| Testes | Minitest, unitários e de integração (44 testes) |
| Modo de codificação | Tradicional |
| Plataforma | Web (responsiva para celular) |

## Funcionalidades

**Cliente:** cadastro com validação de CPF, login/logout com bloqueio por tentativas e expiração de sessão, vitrine com categorias/ordenação/busca com sinônimos, detalhes com alérgenos e avaliações, carrinho (1 a 50 un.), cupom de desconto, checkout com frete por CEP, data/faixa de entrega, pagamento simulado (PIX, cartão até 3×, boleto), acompanhamento com linha do tempo, cancelamento e avaliação após a entrega.

**Administrador:** cadastro pendente de aprovação, login com bloqueio após 3 tentativas, painel com alertas de estoque baixo, CRUD de cupcakes e categorias, ajuste de estoque, gestão de pedidos (fluxo sem pular etapas + histórico), cupons, moderação de avaliações, relatório de vendas (dia/semana/mês, ticket médio, mais vendidos, por categoria; imprimir/PDF). Superadministrador aprova e desbloqueia administradores.

## Como executar localmente

Pré-requisitos: Ruby 3.3+ e Bundler.

```bash
bundle config set --local without production
bundle install
bin/rails db:setup      # cria o banco, roda as migrations e o seed
bin/rails server        # http://localhost:3000
```

Contas de demonstração criadas pelo seed (`db/seeds.rb`), **apenas para teste**:

| Papel | E-mail | Senha |
|---|---|---|
| Superadmin | super@cupcakesgourmet.com.br | `Super@Cupcake2026` |
| Admin | admin@cupcakesgourmet.com.br | `Admin@Cupcake2026` |
| Cliente | cliente@teste.com | `cliente123` |

Cupons: `BEMVINDO10` (10%) e `FRETE5` (R$ 5).

## Testes

```bash
bin/rails test
```

## Publicação no Render (plano gratuito)

O arquivo `render.yaml` descreve o banco PostgreSQL e o serviço web, e o `bin/render-build.sh` instala as dependências, compila os assets, roda as migrations e carrega os dados de demonstração.

1. Suba o repositório no GitHub.
2. No Render, clique em **New > Blueprint**, escolha o repositório e confirme.
3. Quando o Render pedir `RAILS_MASTER_KEY`, cole o conteúdo de `config/master.key` (esse arquivo nunca vai para o GitHub).
4. Aguarde o build terminar e abra a URL `https://<nome>.onrender.com`.

Limitações do plano gratuito: o serviço "dorme" após 15 minutos sem acesso (o primeiro acesso depois disso leva cerca de 1 minuto) e o banco gratuito expira 30 dias após a criação.

## Estrutura

```
app/models        # regras de negócio e validações (Model)
app/services      # Cart, Checkout, PaymentSimulator, Shipping
app/controllers   # loja e admin/ (Controller)
app/views         # telas ERB (View)
config/routes.rb  # Router
db/migrate        # projeto físico do banco
docs/             # documentação do projeto (PIT II)
test/             # testes automatizados
```

## Documentação

1. [Escopo revisado e rastreabilidade](docs/01-escopo-revisado.md)
2. [UML: casos de uso, classes, sequência, estados](docs/02-uml.md)
3. [Projeto de dados: conceitual, lógico, físico](docs/03-banco-de-dados.md)
4. [Dicionário de dados](docs/04-dicionario-de-dados.md)
5. [Interface (IHC)](docs/05-ihc.md)
6. [Plano de testes](docs/06-plano-de-testes.md)
7. [Formulário de teste com usuários e laudo](docs/07-formulario-teste-usuarios.md)

## Limitações conhecidas

Pagamento é **simulado** (sem gateway real); não há envio de e-mails, login social nem notificações push; upload de imagem é por URL. Detalhes e justificativas em `docs/01-escopo-revisado.md`.
