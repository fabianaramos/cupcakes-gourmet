# Dicionário de dados

> Gerado a partir do banco real (`db/schema.rb`). Tipos mostrados na notação do Rails; no PostgreSQL: `string`→`varchar(n)`, `text`→`text`, `decimal`→`numeric(p,s)`, `datetime`→`timestamp`, `boolean`→`boolean`, `bigint`→`bigint`.

## users

Pessoas que acessam o sistema: clientes, administradores e superadministrador.

| Coluna | Tipo | Nulo? | Padrão | Chave | Descrição |
|---|---|---|---|---|---|
| `id` | integer | não |  | PK | Identificador (auto-incremento) |
| `name` | string(120) | não |  |  | Nome completo |
| `email` | string(160) | não |  | UNIQUE | E-mail de login (único; corporativo para admins) |
| `password_digest` | string | não |  |  | Hash bcrypt da senha (a senha nunca é gravada em texto) |
| `cpf` | string(11) | sim |  | UNIQUE | CPF do cliente, só dígitos (único, validado por dígito verificador) |
| `phone` | string(20) | sim |  |  | Telefone, só dígitos |
| `role` | string(20) | não | `cliente` |  | Papel: cliente / admin / superadmin |
| `approved` | boolean | não | `true` |  | Admin aprovado pelo superadmin (clientes nascem aprovados) |
| `failed_attempts` | integer | não | `0` |  | Tentativas de login inválidas seguidas |
| `locked_until` | datetime | sim |  |  | Bloqueado até esta data/hora |
| `created_at` | datetime | não |  |  | Data/hora de criação |
| `updated_at` | datetime | não |  |  | Data/hora de atualização |

**Restrições CHECK:** `role IN ('cliente','admin','superadmin')`

## addresses

Endereços de entrega do cliente (1 cliente : N endereços).

| Coluna | Tipo | Nulo? | Padrão | Chave | Descrição |
|---|---|---|---|---|---|
| `id` | integer | não |  | PK | Identificador (auto-incremento) |
| `user_id` | integer | não |  | FK | FK → users |
| `cep` | string(8) | não |  |  | CEP com 8 dígitos |
| `street` | string(150) | não |  |  | Logradouro |
| `number` | string(10) | não |  |  | Número |
| `complement` | string(60) | sim |  |  | Complemento |
| `neighborhood` | string(80) | não |  |  | Bairro |
| `city` | string(80) | não |  |  | Cidade |
| `state` | string(2) | não |  |  | UF (sigla) |
| `created_at` | datetime | não |  |  | Data/hora de criação |
| `updated_at` | datetime | não |  |  | Data/hora de atualização |

## categories

Categorias da vitrine (Tradicionais, Gourmet, Veganos, Sem glúten).

| Coluna | Tipo | Nulo? | Padrão | Chave | Descrição |
|---|---|---|---|---|---|
| `id` | integer | não |  | PK | Identificador (auto-incremento) |
| `name` | string(60) | não |  | UNIQUE | Nome da categoria (único) |
| `created_at` | datetime | não |  |  | Data/hora de criação |
| `updated_at` | datetime | não |  |  | Data/hora de atualização |

## products

Cupcakes vendidos na loja.

| Coluna | Tipo | Nulo? | Padrão | Chave | Descrição |
|---|---|---|---|---|---|
| `id` | integer | não |  | PK | Identificador (auto-incremento) |
| `category_id` | integer | não |  | FK | FK → categories |
| `name` | string(100) | não |  | UNIQUE | Nome (único) |
| `description` | text | não |  |  | Descrição |
| `ingredients` | text | não |  |  | Ingredientes |
| `allergens` | string(200) | sim |  |  | Alérgenos exibidos em destaque |
| `price` | decimal(8,2) | não |  |  | Preço unitário em R$ (> 0) |
| `stock` | integer | não | `0` |  | Quantidade em estoque (>= 0) |
| `min_stock` | integer | não | `10` |  | Estoque mínimo para alerta (padrão 10) |
| `active` | boolean | não | `false` |  | Publicado na vitrine (novo produto nasce inativo) |
| `image_url` | string(500) | sim |  |  | Foto do catálogo (`cupcakes/<nome>.jpg`) ou link externo |
| `sold_count` | integer | não | `0` |  | Unidades vendidas (ordenação por popularidade) |
| `created_at` | datetime | não |  |  | Data/hora de criação |
| `updated_at` | datetime | não |  |  | Data/hora de atualização |

**Restrições CHECK:** `price > 0`, `stock >= 0`

## coupons

Cupons de desconto.

| Coluna | Tipo | Nulo? | Padrão | Chave | Descrição |
|---|---|---|---|---|---|
| `id` | integer | não |  | PK | Identificador (auto-incremento) |
| `code` | string(30) | não |  | UNIQUE | Código alfanumérico (único, maiúsculas) |
| `kind` | string(12) | não |  |  | percentual / fixo |
| `value` | decimal(8,2) | não |  |  | Valor do desconto (% até 50 ou R$) |
| `valid_until` | date | não |  |  | Última data válida |
| `usage_limit` | integer | não | `100` |  | Máximo de usos |
| `used_count` | integer | não | `0` |  | Usos já realizados |
| `active` | boolean | não | `true` |  | Ativo/desativado pelo admin |
| `created_at` | datetime | não |  |  | Data/hora de criação |
| `updated_at` | datetime | não |  |  | Data/hora de atualização |

**Restrições CHECK:** `kind IN ('percentual','fixo')`, `value > 0`

## orders

Pedidos realizados pelos clientes.

| Coluna | Tipo | Nulo? | Padrão | Chave | Descrição |
|---|---|---|---|---|---|
| `id` | integer | não |  | PK | Identificador (auto-incremento) |
| `user_id` | integer | não |  | FK | FK → users (cliente) |
| `address_id` | integer | não |  | FK | FK → addresses (entrega) |
| `coupon_id` | integer | sim |  | FK | FK → coupons (opcional) |
| `number` | string(20) | não |  | UNIQUE | Número de protocolo (único) |
| `status` | string(20) | não | `recebido` |  | recebido / confirmado / em_preparo / saiu_para_entrega / entregue / cancelado |
| `subtotal` | decimal(10,2) | não |  |  | Soma dos itens |
| `discount` | decimal(10,2) | não | `0.0` |  | Desconto do cupom |
| `shipping` | decimal(10,2) | não |  |  | Frete calculado pelo CEP |
| `total` | decimal(10,2) | não |  |  | subtotal − desconto + frete |
| `payment_method` | string(10) | não |  |  | pix / cartao / boleto |
| `installments` | integer | não | `1` |  | Parcelas (1 a 3, só cartão > R$ 60) |
| `payment_code` | string(120) | sim |  |  | Código PIX / autorização / linha do boleto (simulados) |
| `paid_at` | datetime | sim |  |  | Data/hora da confirmação do pagamento |
| `delivery_date` | date | não |  |  | Data de entrega escolhida |
| `delivery_period` | string(10) | não |  |  | manha / tarde / noite |
| `created_at` | datetime | não |  |  | Data/hora de criação |
| `updated_at` | datetime | não |  |  | Data/hora de atualização |

**Restrições CHECK:** `status IN ('recebido','confirmado','em_preparo','saiu_para_entrega','entregue','cancelado')`, `payment_method IN ('cartao','pix','boleto')`

## order_items

Itens de cada pedido (resolve o N:N entre pedidos e produtos).

| Coluna | Tipo | Nulo? | Padrão | Chave | Descrição |
|---|---|---|---|---|---|
| `id` | integer | não |  | PK | Identificador (auto-incremento) |
| `order_id` | integer | não |  | FK | FK → orders |
| `product_id` | integer | não |  | FK | FK → products |
| `quantity` | integer | não |  |  | Quantidade (1 a 50) |
| `unit_price` | decimal(8,2) | não |  |  | Preço no momento da compra (histórico) |
| `created_at` | datetime | não |  |  | Data/hora de criação |
| `updated_at` | datetime | não |  |  | Data/hora de atualização |

**Restrições CHECK:** `quantity BETWEEN 1 AND 50`

## order_status_changes

Histórico de mudanças de status (auditoria, US-016 CA#3).

| Coluna | Tipo | Nulo? | Padrão | Chave | Descrição |
|---|---|---|---|---|---|
| `id` | integer | não |  | PK | Identificador (auto-incremento) |
| `order_id` | integer | não |  | FK | FK → orders |
| `user_id` | integer | sim |  | FK | FK → users (quem alterou; nulo = sistema/pagamento) |
| `from_status` | string(20) | sim |  |  | Status anterior |
| `to_status` | string(20) | não |  |  | Novo status |
| `created_at` | datetime | não |  |  | Data/hora de criação |

## reviews

Avaliações de produtos comprados (US-013).

| Coluna | Tipo | Nulo? | Padrão | Chave | Descrição |
|---|---|---|---|---|---|
| `id` | integer | não |  | PK | Identificador (auto-incremento) |
| `user_id` | integer | não |  | FK | FK → users |
| `product_id` | integer | não |  | FK | FK → products |
| `order_id` | integer | não |  | FK | FK → orders |
| `rating` | integer | não |  |  | Nota de 1 a 5 |
| `comment` | text | sim |  |  | Comentário opcional |
| `approved` | boolean | não | `false` |  | Publicada após moderação |
| `created_at` | datetime | não |  |  | Data/hora de criação |
| `updated_at` | datetime | não |  |  | Data/hora de atualização |

**Restrições CHECK:** `rating BETWEEN 1 AND 5`

