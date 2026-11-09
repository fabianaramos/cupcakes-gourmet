ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module TestFactories
  VALID_CPFS = %w[52998224725 11144477735 12345678909 98765432100 39053344705].freeze

  def create_client(attrs = {})
    @cpf_index = (@cpf_index || -1) + 1
    user = User.create!({ name: "Cliente Teste", email: "cliente#{SecureRandom.hex(3)}@teste.com",
                          cpf: VALID_CPFS[@cpf_index % VALID_CPFS.size], password: "senha1234" }.merge(attrs))
    user.addresses.create!(cep: "01310100", street: "Av. Paulista", number: "1000", neighborhood: "Bela Vista", city: "São Paulo", state: "SP")
    user
  end

  def create_admin(attrs = {})
    User.create!({ name: "Admin", email: "admin#{SecureRandom.hex(3)}@#{User::CORPORATE_DOMAIN}",
                   role: "admin", password: "Admin@12345" }.merge(attrs))
  end

  def create_product(attrs = {})
    category = Category.first || Category.create!(name: "Gourmet")
    Product.create!({ name: "Cupcake #{SecureRandom.hex(3)}", description: "Delicioso", ingredients: "Farinha, ovos",
                      allergens: "Glúten", price: 10, stock: 20, active: true, category: category }.merge(attrs))
  end

  def next_delivery_day
    d = Date.tomorrow
    d += 1 until Order.delivery_day?(d)
    d
  end

  def place_order(user, product, qty: 3, payment: "pix", coupon_code: nil)
    session = {}
    cart = Cart.new(session)
    cart.add(product, qty)
    Checkout.new(user: user, cart: cart, params: { address_id: user.addresses.first.id, payment_method: payment,
                                                   delivery_date: next_delivery_day, delivery_period: "tarde",
                                                   coupon_code: coupon_code }).call
  end
end

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    include TestFactories
  end
end
