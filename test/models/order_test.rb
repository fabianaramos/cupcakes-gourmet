require "test_helper"

class OrderTest < ActiveSupport::TestCase
  setup do
    @client = create_client
    @product = create_product(price: 10, stock: 20)
    @admin = create_admin
  end

  test "US-010 RN#1: pedido mínimo de R$ 25,00" do
    result = place_order(@client, @product, qty: 2)
    assert_not result.success?
    assert_match "pedido mínimo", result.errors.join.downcase
    assert_equal 20, @product.reload.stock, "estoque não deve mudar"
  end

  test "US-010/US-011: checkout com PIX confirma automaticamente e baixa estoque" do
    result = place_order(@client, @product, qty: 3)
    assert result.success?, result.errors.inspect
    order = result.order
    assert_equal "confirmado", order.status
    assert order.paid?
    assert_match(/\ACP\d+/, order.number)
    assert_equal 30, order.subtotal
    assert_equal 8, order.shipping
    assert_equal 38, order.total
    assert_equal 17, @product.reload.stock
    assert_equal %w[recebido confirmado], order.status_changes.map(&:to_status)
  end

  test "US-011: boleto fica aguardando pagamento" do
    order = place_order(@client, @product, qty: 3, payment: "boleto").order
    assert_equal "recebido", order.status
    assert_not order.paid?
    assert order.payment_code.present?
  end

  test "US-009: cupom aplicado no checkout e uso contabilizado" do
    coupon = Coupon.create!(code: "DEZ", kind: "percentual", value: 10, valid_until: Date.tomorrow)
    order = place_order(@client, @product, qty: 3, coupon_code: "dez").order
    assert_equal 3, order.discount
    assert_equal 1, coupon.reload.used_count
  end

  test "checkout recusa quantidade acima do estoque" do
    @product.update!(stock: 3)
    cart = Cart.new({})
    cart.raw[@product.id.to_s] = 5
    result = Checkout.new(user: @client, cart: cart, params: { address_id: @client.addresses.first.id, payment_method: "pix",
                                                              delivery_date: next_delivery_day, delivery_period: "tarde" }).call
    assert_not result.success?
    assert_match "Estoque insuficiente", result.errors.join
  end

  test "US-019: entrega não pode ser hoje nem domingo" do
    order = Order.new(delivery_date: Date.current, delivery_period: "manha", payment_method: "pix", subtotal: 30, total: 38)
    order.valid?
    assert order.errors[:delivery_date].any?
    sunday = Date.current.next_occurring(:sunday)
    order.delivery_date = sunday
    order.valid?
    assert_includes order.errors[:delivery_date], "não pode ser domingo ou feriado"
  end

  test "US-011 RN#1: parcelamento só no cartão acima de R$ 60" do
    order = Order.new(payment_method: "cartao", installments: 3, total: 50)
    order.valid?
    assert order.errors[:installments].any?
    order.total = 61
    order.valid?
    assert_empty order.errors[:installments]
  end

  test "US-016 RN#1: status segue o fluxo sem pular etapas" do
    order = place_order(@client, @product).order
    %w[em_preparo saiu_para_entrega entregue].each do |expected|
      order.advance!(by: @admin)
      assert_equal expected, order.status
    end
    assert_raises(Order::StatusError) { order.advance!(by: @admin) }
    assert_equal 5, order.status_changes.count, "CA#3: histórico registrado"
  end

  test "US-018 RN#1: cliente não cancela pedido em preparo" do
    order = place_order(@client, @product).order
    order.advance!(by: @admin)
    assert_raises(Order::StatusError) { order.cancel!(by: @client) }
  end

  test "US-018 / US-016 RN#2: cancelamento devolve estoque e trava o status" do
    order = place_order(@client, @product, qty: 4).order
    assert_equal 16, @product.reload.stock
    order.cancel!(by: @client)
    assert_equal "cancelado", order.status
    assert_equal 20, @product.reload.stock
    assert_raises(Order::StatusError) { order.advance!(by: @admin) }
  end
end
