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
end
