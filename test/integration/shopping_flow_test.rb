require "test_helper"

class ShoppingFlowTest < ActionDispatch::IntegrationTest
  setup do
    @product = create_product(name: "Red Velvet", price: 12, stock: 10)
  end

  test "vitrine lista produtos disponíveis e filtra por busca" do
    hidden = create_product(name: "Escondido", active: false)
    get root_path
    assert_response :success
    assert_select "h3", text: "Red Velvet"
    assert_select "h3", text: hidden.name, count: 0

    get products_path(q: "zzz")
    assert_select ".empty", /Nenhum cupcake encontrado/
  end

  test "detalhe do produto exibe alérgenos" do
    get product_path(@product)
    assert_response :success
    assert_select ".allergens", /Glúten/
  end

  test "cadastro de cliente com endereço e login automático" do
    post signup_path, params: {
      user: { name: "Nova Cliente", email: "nova@teste.com", cpf: "111.444.777-35", phone: "11988887777",
              password: "senha1234", password_confirmation: "senha1234" },
      address: { cep: "01310-100", street: "Rua A", number: "1", neighborhood: "Centro", city: "São Paulo", state: "SP" }
    }
    assert_redirected_to root_path
    follow_redirect!
    assert_select ".flash-notice", /Cadastro realizado/
    assert_select "a", text: "Meus pedidos"
  end

  test "cadastro inválido mostra mensagens claras" do
    post signup_path, params: { user: { name: "", email: "x", cpf: "123", password: "1" },
                                address: { cep: "1" } }
    assert_response :unprocessable_entity
    assert_select ".error-box li", minimum: 3
  end

  test "fluxo completo: carrinho → login → checkout → acompanhar → cancelar" do
    client = create_client(email: "fluxo@teste.com")

    post add_cart_path, params: { product_id: @product.id, quantity: 3 }
    get cart_path
    assert_select "#cart-count", "3"

    get checkout_path
    assert_redirected_to login_path

    post login_path, params: { email: "fluxo@teste.com", password: "senha1234" }
    assert_redirected_to checkout_path
    follow_redirect!
    assert_response :success

    post checkout_path, params: { order: { address_id: client.addresses.first.id, payment_method: "pix",
                                           delivery_date: next_delivery_day, delivery_period: "manha", installments: 1 } }
    order = client.orders.last
    assert_redirected_to order_path(order)
    follow_redirect!
    assert_select ".badge", "Confirmado"
    assert_select "#pix"
    assert_equal 7, @product.reload.stock

    patch cancel_order_path(order)
    follow_redirect!
    assert_select ".badge", "Cancelado"
    assert_equal 10, @product.reload.stock
  end

  test "US-002: login inválido exibe erro e bloqueia após 5 tentativas" do
    create_client(email: "bloq@teste.com")
    5.times { post login_path, params: { email: "bloq@teste.com", password: "errada" } }
    assert_response :unprocessable_entity
    assert_select ".flash-alert", /bloqueada/
    post login_path, params: { email: "bloq@teste.com", password: "senha1234" }
    assert_select ".flash-alert", /bloqueada/
  end

  test "US-003: sessão expira após 30 minutos de inatividade" do
    create_client(email: "sessao@teste.com")
    post login_path, params: { email: "sessao@teste.com", password: "senha1234" }
    travel 31.minutes do
      get orders_path
      assert_redirected_to login_path
    end
  end

  test "cliente não vê pedido de outro cliente" do
    other = create_client
    order = place_order(other, @product).order
    create_client(email: "curioso@teste.com")
    post login_path, params: { email: "curioso@teste.com", password: "senha1234" }
    get order_path(order)
    assert_redirected_to orders_path
  end
end
