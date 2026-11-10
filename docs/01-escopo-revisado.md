# 1. Escopo revisado (PIT II)

Revisão da especificação ágil entregue no PIT I (22 histórias, 107 pontos) para torná-la executável neste semestre, aplicando melhoria contínua (Kaizen).

## Decisões de revisão

| Tema | PIT I (planejado) | PIT II (revisado) | Motivo |
|---|---|---|---|
| Plataforma | App mobile nativo | **Aplicação web responsiva** (mobile-first), utilizável no navegador do celular | O material permite web ou mobile; uma única base de código para cliente e admin, publicável e testável por colegas via link |
| Linguagem / arquitetura | não definida | **Ruby on Rails 8 (MVC)** | Rails implementa o padrão MVC recomendado no material (Model-View-Controller + Router) |
| Banco de dados | não definido | **SQLite** (desenvolvimento/testes) e **PostgreSQL** (produção) | SGBDs populares e de fácil manutenção; mesmas migrations para ambos |
| Pagamento (US-011) | Gateway real (cartão, PIX, boleto) | **Gateway simulado**: PIX e cartão aprovam na hora; boleto aguarda confirmação do admin | Integração real exige conta empresarial e chaves de produção; regras de negócio (parcelamento, vencimento, não armazenar cartão) foram mantidas |
| Login social (US-001/002) | Google / Facebook | **Fora do escopo** | Depende de credenciais OAuth de terceiros |
| E-mails (confirmação, recuperação de senha, aprovação de admin) | Envio automático | **Fora do escopo**: mensagens exibidas na tela | Exige provedor SMTP; registrado como evolução |
| Notificações push (US-012) | Push no celular | **Linha do tempo do pedido** com data/hora de cada status | Push exige app nativo/serviço externo |
| Autenticação admin (US-022 RNF) | Token JWT | **Sessão em cookie criptografado** do Rails, com expiração por inatividade | Em aplicação web server-side a sessão é o mecanismo padrão e seguro; JWT é indicado para APIs consumidas por apps nativos |
| Entrega expressa (US-019 CA#3) | Mesmo dia com taxa | **Fora do escopo**; mantidas datas a partir de amanhã, sem domingos/feriados | Prioridade C |
| Upload de fotos (US-014 CA#2) | Até 5 fotos | **1 imagem por URL** (ou ilustração padrão) | Evita armazenamento de arquivos na hospedagem gratuita |
| Relatório em PDF (US-017 CA#3) | Exportar PDF | **Imprimir / Salvar como PDF** pelo navegador (layout de impressão) | Mesmo resultado sem biblioteca extra |

## Rastreabilidade: histórias × implementação

| História | Situação | Onde |
|---|---|---|
| US-001 Cadastro de cliente | Sim (sem login social e e-mail) | `RegistrationsController`, `User` |
| US-002 Login do cliente | Sim (bloqueio 5 tentativas/15 min; sem recuperação por e-mail) | `SessionsController` |
| US-003 Logout | Sim (expira após 30 min) | `ApplicationController#expire_idle_session` |
| US-004 Vitrine | Sim: filtros por categoria e ordenação | `ProductsController#index` |
| US-005 Detalhes | Sim: alérgenos destacados, avaliações | `ProductsController#show` |
| US-006 Busca | Sim: parcial, ingredientes, sinônimos, sugestões | `Product.search` |
| US-007 Adicionar ao carrinho | Sim: 1 a 50 un., limitado ao estoque | `Cart`, `CartsController` |
| US-008 Remover do carrinho | Sim: com confirmação | `CartsController#remove` |
| US-009 Cupom | Sim: 1 por pedido, máx. 50% | `Coupon`, `CartsController#apply_coupon` |
| US-010 Checkout | Sim: mínimo R$ 25, frete por CEP, protocolo | `Checkout`, `Shipping` |
| US-011 Pagamento | Parcial: simulado | `PaymentSimulator` |
| US-012 Acompanhar pedido | Sim: linha do tempo e histórico (sem push) | `OrdersController` |
| US-013 Avaliar | Sim: após entrega, moderação, filtro de palavras | `Review` |
| US-014 Cadastrar cupcake | Sim: nasce inativo (1 imagem) | `Admin::ProductsController` |
| US-015 Estoque | Sim: alerta de mínimo, oculta sem estoque | `Admin::ProductsController#stock`, dashboard |
| US-016 Status do pedido | Sim: sem pular etapas, histórico | `Order#advance!` |
| US-017 Relatórios | Sim: dia/semana/mês, ticket médio, PDF via impressão | `Admin::ReportsController` |
| US-018 Cancelar pedido | Sim: até "Confirmado", devolve estoque | `Order#cancel!` |
| US-019 Data/horário | Sim (sem expressa) | `Order` validações |
| US-020 Cupons (admin) | Sim: busca e filtros | `Admin::CouponsController` |
| US-021 Cadastro admin | Sim: e-mail corporativo, aprovação do superadmin (sem e-mail) | `Admin::RegistrationsController` |
| US-022 Login admin | Sim: bloqueio após 3, sessão 15 min (sessão em vez de JWT) | `Admin::SessionsController` |
