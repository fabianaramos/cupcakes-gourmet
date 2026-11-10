# 5. Interface (IHC)

## Mapa de telas

| Área | Tela | Rota |
|---|---|---|
| Loja | Vitrine (busca, categorias, ordenação) | `/` |
| Loja | Detalhes do cupcake | `/cupcakes/:id` |
| Loja | Carrinho + cupom | `/carrinho` |
| Loja | Cadastro (dados → endereço → senha) | `/cadastro` |
| Loja | Login | `/entrar` |
| Loja | Checkout (endereço → data → pagamento → resumo) | `/checkout` |
| Loja | Meus pedidos / pedido com linha do tempo | `/pedidos`, `/pedidos/:id` |
| Admin | Login / solicitação de cadastro | `/admin/entrar`, `/admin/cadastro` |
| Admin | Visão geral (alertas de estoque, pendências) | `/admin` |
| Admin | Pedidos (filtro por status, paginação) | `/admin/pedidos` |
| Admin | Cupcakes / Categorias / Cupons / Avaliações | `/admin/cupcakes` etc. |
| Admin | Relatórios | `/admin/relatorios` |
| Admin | Administradores (só superadmin) | `/admin/administradores` |

## Princípios aplicados (material teórico)

- **Clara / simples:** um objetivo por tela; cadastro em 3 blocos (RNF US-001: até 3 etapas); checkout em 4 blocos (RNF US-010).
- **Consistente:** mesmos componentes e mensagens em loja e painel; a cor de destaque fica reservada para as ações principais.
- **Identidade visual da loja:** estética de confeitaria, com fundo creme (#fff8f1), rosa claro (#fde3ea) em detalhes, vinho (#7a0f2a) nos títulos, no banner e no rodapé (o topo e o fim da página usam a mesma cor para formar uma moldura) e cereja (#c8174a) nos botões. Títulos em DM Serif Display, textos em DM Sans e a marca no rodapé em Bagel Fat One. Elementos decorativos: cobertura escorrendo abaixo do banner, faixa quadriculada antes do rodapé e selos redondos nos produtos. Todas as combinações de texto e fundo têm contraste de pelo menos 4,5:1 (WCAG AA); os ícones são desenhos em SVG, sem emojis. O painel administrativo mantém um visual neutro, focado em produtividade.
- **Controlada pelo usuário e reversível:** confirmação antes de remover item, sair, cancelar pedido ou excluir; quantidade editável no carrinho.
- **Feedback imediato:** mensagens verdes (sucesso) e vermelhas (erro) no topo; campos com erro destacados; contador do carrinho; total do checkout recalcula ao trocar endereço/parcelamento.
- **Padrões (defaults):** próxima data de entrega válida e PIX pré-selecionados; primeiro endereço marcado.
- **Acessibilidade:** `lang="pt-BR"`, rótulos em todos os campos, `role="alert"` nas mensagens, contraste AA, navegação por teclado, layout mobile-first.

## Mensagens de erro (exemplos)

| Situação | Mensagem |
|---|---|
| Login inválido | "E-mail ou senha incorretos." |
| 5 tentativas (cliente) | "Conta bloqueada por 15 minutos após 5 tentativas inválidas." |
| 3 tentativas (admin) | "Conta bloqueada após 3 tentativas. O superadministrador foi notificado." |
| CPF inválido | "CPF é inválido" |
| Senha fraca | "Senha deve ter no mínimo 8 caracteres, com letras e números" |
| Pedido abaixo do mínimo | "Pedido mínimo de R$ 25,00. Faltam R$ X." |
| Cupom | "Cupom inválido." / "Cupom expirado." / "Cupom esgotado." |
| Data de entrega | "Data de entrega não pode ser domingo ou feriado" |
| Estoque | "Estoque insuficiente para Red Velvet (disponível: 3)." |
| Cancelamento tardio | "Pedidos em preparo ou posteriores não podem ser cancelados pelo cliente." |
| Sessão | "Sua sessão expirou por inatividade. Entre novamente." |
