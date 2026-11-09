require "test_helper"

class CartTest < ActiveSupport::TestCase
  test "US-007 RN#1/RN#2: quantidade entre 1 e 50 e limitada ao estoque" do
    product = create_product(stock: 100)
    cart = Cart.new({})
    assert_equal 50, cart.set(product, 80)
    assert_equal 1, cart.set(product, 0)
    product.update!(stock: 5)
    assert_equal 5, cart.set(product, 10)
  end

  test "US-008 CA#2: subtotal recalculado ao remover" do
    a = create_product(price: 10)
    b = create_product(price: 5)
    cart = Cart.new({})
    cart.add(a, 2)
    cart.add(b, 1)
    assert_equal 25, cart.subtotal
    cart.remove(b.id)
    assert_equal 20, cart.subtotal
    assert_equal 2, cart.count
  end
end
