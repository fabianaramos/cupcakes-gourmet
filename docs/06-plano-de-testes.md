# 6. Testes — verificação e validação

Seguindo o **Modelo V** do material:

| Nível | O que verifica | Como |
|---|---|---|
| Teste unitário | Regras de negócio de cada model/serviço | Minitest — `test/models/*` |
| Teste de integração | Fluxos HTTP completos (controller + view + banco) | Minitest — `test/integration/*` |
| Teste de sistema | Aplicação rodando no navegador | Roteiro manual abaixo |
| Teste de aceitação | 5 colegas usando a versão publicada | Formulário em [`07-formulario-teste-usuarios.md`](07-formulario-teste-usuarios.md) |

## Testes automatizados

```bash
bin/rails test
```

Resultado na última execução: **44 testes, 174 verificações, 0 falhas, 0 erros.**

Cada teste tem no nome a história/regra que cobre (ex.: `US-018 RN#1: cliente não cancela pedido em preparo`), garantindo rastreabilidade requisito → código → teste.

| Arquivo | Cobre |
|---|---|
| `test/models/user_test.rb` | US-001 (e-mail único, senha, CPF), US-002 (bloqueio 5×), US-021 (e-mail corporativo, senha forte), US-022 (bloqueio 3×) |
| `test/models/product_test.rb` | US-014 (nome único, preço), US-015 (estoque, alerta), US-004 (vitrine), US-006 (busca/sinônimos) |
| `test/models/coupon_test.rb` | US-009, US-020 |
| `test/models/cart_test.rb` | US-007 (1–50, estoque), US-008 (recalcular total) |
| `test/models/order_test.rb` | US-010 (mínimo, totais), US-011 (PIX/boleto, parcelamento), US-016 (fluxo), US-018 (cancelamento), US-019 (datas), estoque insuficiente |
| `test/models/review_test.rb` | US-013 |
| `test/integration/shopping_flow_test.rb` | Vitrine, cadastro, login/bloqueio, sessão expirada, fluxo completo de compra e cancelamento, acesso indevido a pedido alheio |
| `test/integration/admin_flow_test.rb` | Acesso restrito, aprovação de admin, cadastro de cupcake, estoque, status do pedido, relatório, bloqueio do admin |

## Roteiro de teste de sistema (manual)

| # | Passo | Resultado esperado |
|---|---|---|
| 1 | Abrir a vitrine, filtrar "Veganos", buscar "cacau" | Só itens da categoria; busca encontra "Chocolate Belga" |
| 2 | Adicionar 1 item de R$ 12,50 e abrir o carrinho | Aviso de pedido mínimo, sem botão de finalizar |
| 3 | Aumentar quantidade para 3, aplicar `BEMVINDO10` | Desconto de 10% exibido |
| 4 | Finalizar pedido sem estar logado | Redireciona ao login e volta ao checkout |
| 5 | Escolher um domingo como data | Mensagem de erro de data |
| 6 | Pagar com PIX | Pedido "Confirmado" com código copia-e-cola |
| 7 | Cancelar o pedido | Status "Cancelado", estoque devolvido |
| 8 | Admin: avançar status de outro pedido até "Entregue" | Cada clique avança uma etapa; histórico registrado |
| 9 | Cliente: avaliar item entregue; admin publica | Avaliação aparece na página do cupcake |
| 10 | Admin: zerar estoque de um cupcake | Some da vitrine; alerta de estoque baixo no painel |
