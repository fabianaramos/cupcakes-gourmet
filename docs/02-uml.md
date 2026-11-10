# 2. Modelagem UML

Diagramas em Mermaid (o GitHub renderiza automaticamente).

## 2.1 Casos de uso

```mermaid
flowchart LR
  C([Cliente]) --- UC1[Cadastrar-se / Entrar / Sair]
  C --- UC2[Navegar na vitrine e buscar]
  C --- UC3[Ver detalhes do cupcake]
  C --- UC4[Gerenciar carrinho e aplicar cupom]
  C --- UC5[Finalizar pedido e pagar]
  C --- UC6[Acompanhar / cancelar pedido]
  C --- UC7[Avaliar cupcake entregue]
  A([Administrador]) --- UA1[Solicitar cadastro / Entrar]
  A --- UA2[Cadastrar cupcakes e categorias]
  A --- UA3[Ajustar estoque]
  A --- UA4[Avançar / cancelar pedidos]
  A --- UA5[Gerenciar cupons]
  A --- UA6[Moderar avaliações]
  A --- UA7[Ver relatório de vendas]
  S([Superadministrador]) --- US1[Aprovar administradores]
  S --- US2[Desbloquear contas]
  S -. herda .-> A
  UC5 -. include .-> PG[[Gateway de pagamento simulado]]
```

## 2.2 Diagrama de classes (persistência)

```mermaid
classDiagram
  class User { +name +email +cpf +phone +role +approved +failed_attempts +locked_until
    +locked?() +register_failed_login!() +unlock!() }
  class Address { +cep +street +number +complement +neighborhood +city +state }
  class Category { +name }
  class Product { +name +description +ingredients +allergens +price +stock +min_stock +active +image_url +sold_count
    +available?() +low_stock?() +search(term)$ }
  class Coupon { +code +kind +value +valid_until +usage_limit +used_count +active
    +usable?() +discount_for(subtotal) }
  class Order { +number +status +subtotal +discount +shipping +total +payment_method +installments +payment_code +paid_at +delivery_date +delivery_period
    +advance!(by) +cancel!(by) +next_status() }
  class OrderItem { +quantity +unit_price +total() }
  class OrderStatusChange { +from_status +to_status +created_at }
  class Review { +rating +comment +approved }
  User "1" --> "0..*" Address
  User "1" --> "0..*" Order
  User "1" --> "0..*" Review
  Category "1" --> "0..*" Product
  Order "1" *-- "1..*" OrderItem
  OrderItem "0..*" --> "1" Product
  Order "0..*" --> "1" Address
  Order "0..*" --> "0..1" Coupon
  Order "1" *-- "1..*" OrderStatusChange
  Review "0..*" --> "1" Product
  Review "0..*" --> "1" Order
```

Classes de serviço (não persistidas): `Cart` (carrinho na sessão), `Checkout` (transforma carrinho em pedido), `PaymentSimulator`, `Shipping`.

## 2.3 Sequência: finalizar pedido (US-010/US-011)

```mermaid
sequenceDiagram
  actor Cliente
  participant V as View (checkout)
  participant CC as CheckoutsController
  participant CK as Checkout (serviço)
  participant DB as Banco de dados
  participant PS as PaymentSimulator
  Cliente->>V: escolhe endereço, data, pagamento
  V->>CC: POST /checkout
  CC->>CK: call(user, cart, params)
  CK->>DB: BEGIN; SELECT products FOR UPDATE
  alt estoque insuficiente ou regra violada
    CK-->>CC: erros
    CC-->>V: re-exibe formulário com mensagens
  else ok
    CK->>DB: INSERT orders, order_items; UPDATE stock, coupon
    CK->>PS: process!(order)
    PS->>DB: status = confirmado (PIX/cartão) ou mantém recebido (boleto)
    CK->>DB: COMMIT
    CC-->>Cliente: redirect para /pedidos/:id (protocolo)
  end
```

## 2.4 Estados do pedido (US-016/US-018)

```mermaid
stateDiagram-v2
  [*] --> recebido: checkout
  recebido --> confirmado: pagamento aprovado / admin
  confirmado --> em_preparo: admin
  em_preparo --> saiu_para_entrega: admin
  saiu_para_entrega --> entregue: admin
  recebido --> cancelado: cliente ou admin
  confirmado --> cancelado: cliente ou admin
  em_preparo --> cancelado: somente admin
  saiu_para_entrega --> cancelado: somente admin
  entregue --> [*]
  cancelado --> [*]
```

## 2.5 Atividade: arquitetura MVC da aplicação

```mermaid
flowchart LR
  U[Usuário / navegador] -- requisição HTTP --> R[Router<br/>config/routes.rb]
  R --> C[Controller<br/>app/controllers]
  C <--> M[Model<br/>app/models + services]
  M <--> DB[(SQLite / PostgreSQL)]
  C --> V[View ERB<br/>app/views]
  V -- HTML --> U
```
