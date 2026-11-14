require "test_helper"

class AdminFlowTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_admin(email: "gestor@#{User::CORPORATE_DOMAIN}")
  end

  def login_admin
    post admin_login_path, params: { email: @admin.email, password: "Admin@12345" }
  end

  test "painel exige login administrativo" do
    get admin_products_path
    assert_redirected_to admin_login_path
    client = create_client(email: "c@teste.com")
    post login_path, params: { email: client.email, password: "senha1234" }
    get admin_products_path
    assert_redirected_to admin_login_path
  end

  test "US-021: novo admin fica pendente até aprovação do superadmin" do
    post admin_signup_path, params: { user: { name: "Novo", email: "novo@#{User::CORPORATE_DOMAIN}",
                                               password: "Novo@123456", password_confirmation: "Novo@123456" } }
    assert_redirected_to admin_login_path
    post admin_login_path, params: { email: "novo@#{User::CORPORATE_DOMAIN}", password: "Novo@123456" }
    assert_select ".flash-alert", /aguardando aprovação/

    superadmin = create_admin(role: "superadmin")
    post admin_login_path, params: { email: superadmin.email, password: "Admin@12345" }
    patch approve_admin_user_path(User.find_by(email: "novo@#{User::CORPORATE_DOMAIN}"))
    assert User.find_by(email: "novo@#{User::CORPORATE_DOMAIN}").approved?
  end

  test "US-014: cadastro de cupcake salvo como inativo e validações" do
    login_admin
    category = Category.create!(name: "Veganos")
    post admin_products_path, params: { product: { name: "Novo", description: "d", ingredients: "i", price: 9, stock: 5, category_id: category.id, active: "0" } }
    assert_redirected_to admin_products_path
    assert_not Product.find_by(name: "Novo").active?

    post admin_products_path, params: { product: { name: "", price: 0, category_id: category.id } }
    assert_response :unprocessable_entity
  end

  test "US-015: ajuste de estoque com alerta e rejeição de negativo" do
    login_admin
    product = create_product(stock: 50)
    patch stock_admin_product_path(product), params: { stock: 4 }
    follow_redirect!
    assert_select ".flash-notice", /abaixo do mínimo/
    patch stock_admin_product_path(product), params: { stock: -2 }
    assert_equal 4, product.reload.stock
  end

  test "US-016: admin avança status do pedido" do
    login_admin
    order = place_order(create_client, create_product(price: 10)).order
    patch advance_admin_order_path(order)
    assert_equal "em_preparo", order.reload.status
    assert_equal @admin, order.status_changes.last.user
  end

  test "US-017: relatório calcula total e ticket médio" do
    login_admin
    product = create_product(price: 10)
    place_order(create_client, product, qty: 3)
    get admin_reports_path(periodo: "dia")
    assert_response :success
    assert_select ".stat .n", /38,00/
  end

  test "US-022: admin bloqueado após 3 tentativas inválidas" do
    3.times { post admin_login_path, params: { email: @admin.email, password: "errada" } }
    assert @admin.reload.locked?
    post admin_login_path, params: { email: @admin.email, password: "Admin@12345" }
    assert_select ".flash-alert", /bloqueada/
  end
  test "superadmin desativa admin, que perde o acesso ao painel" do
    superadmin = create_admin(role: "superadmin")
    login_admin
    get admin_root_path
    assert_response :success

    open_session do |sup|
      sup.post admin_login_path, params: { email: superadmin.email, password: "Admin@12345" }
      sup.patch deactivate_admin_user_path(@admin)
      sup.patch deactivate_admin_user_path(superadmin)
      sup.follow_redirect!
      assert_match "não pode desativar a própria conta", sup.response.body
    end
    assert_not @admin.reload.active?
    assert superadmin.reload.active?

    get admin_root_path
    assert_redirected_to admin_login_path
    post admin_login_path, params: { email: @admin.email, password: "Admin@12345" }
    assert_select ".flash-alert", /desativado/
  end

  test "filtro Todos nos pedidos e confirmação ao avançar status" do
    client = create_client(email: "todos@teste.com")
    product = create_product(price: 15)
    order = place_order(client, product, qty: 2).order
    order.update_columns(status: "entregue")
    login_admin
    get admin_orders_path
    assert_no_match order.number, response.body
    get admin_orders_path(status: "todos")
    assert_match order.number, response.body

    other = place_order(client, product, qty: 2).order
    get admin_orders_path
    assert_select "form[data-turbo-confirm*='#{other.number}']"
  end

  test "cupcakes ordenados pelo menor estoque" do
    create_product(name: "Muito", stock: 90)
    create_product(name: "Pouco", stock: 1)
    login_admin
    get admin_products_path(ordem: "estoque")
    names = css_select("tbody tr td:first-child").map { |td| td.text.strip }
    assert_equal "Pouco", names.first
  end

  test "pedido mostra o cupom usado; cupcakes com situação colorida e prévia da imagem" do
    client = create_client(email: "cupom@teste.com")
    product = create_product(price: 15)
    create_product(name: "Escondido", active: false)
    Coupon.create!(code: "VERDE10", kind: "percentual", value: 10, valid_until: Date.tomorrow)
    order = place_order(client, product, qty: 2, coupon_code: "VERDE10").order
    login_admin
    get admin_order_path(order)
    assert_match "cupom VERDE10", response.body

    get admin_products_path
    assert_select "span.situacao-publicado", text: "Publicado"
    assert_select "span.situacao-inativo", text: "Inativo"

    get edit_admin_product_path(product)
    assert_select "[data-controller='image-preview'] figure.image-preview img"
  end
end
