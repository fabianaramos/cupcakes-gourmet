# Transforma o carrinho em pedido: valida estoque, aplica cupom, calcula frete,
# simula o pagamento e baixa o estoque, tudo em uma transação.
class Checkout
  Result = Struct.new(:order, :errors) do
    def success? = errors.empty?
  end

  def initialize(user:, cart:, params:)
    @user = user
    @cart = cart
    @params = params
  end

  def call
    order = Order.new(user: @user)
    errors = []
    lines = @cart.lines
    return Result.new(order, [ "Seu carrinho está vazio." ]) if lines.empty?

    address = @user.addresses.find_by(id: @params[:address_id])
    return Result.new(order, [ "Selecione um endereço de entrega." ]) if address.nil?

    coupon = nil
    if @params[:coupon_code].present?
      coupon = Coupon.find_by(code: @params[:coupon_code].strip.upcase)
      return Result.new(order, [ "Cupom inválido." ]) if coupon.nil?
      return Result.new(order, [ coupon.unusable_reason ]) unless coupon.usable?
    end

    ActiveRecord::Base.transaction do
      subtotal = BigDecimal("0")
      lines.each do |line|
        product = Product.lock.find(line.product.id)
        if product.stock < line.quantity
          errors << "Estoque insuficiente para #{product.name} (disponível: #{product.stock})."
          next
        end
        order.order_items.build(product: product, quantity: line.quantity, unit_price: product.price)
        subtotal += product.price * line.quantity
      end
      raise ActiveRecord::Rollback if errors.any?

      discount = coupon ? coupon.discount_for(subtotal) : 0
      shipping = Shipping.price_for(address.cep)
      order.assign_attributes(
        address: address, coupon: coupon, subtotal: subtotal, discount: discount, shipping: shipping,
        total: subtotal - discount + shipping,
        payment_method: @params[:payment_method], installments: (@params[:installments].presence || 1).to_i,
        delivery_date: @params[:delivery_date], delivery_period: @params[:delivery_period]
      )

      unless order.save
        errors.concat(order.errors.full_messages)
        raise ActiveRecord::Rollback
      end

      order.order_items.each do |item|
        item.product.decrement!(:stock, item.quantity)
        item.product.increment!(:sold_count, item.quantity)
      end
      coupon&.increment!(:used_count)
      order.status_changes.create!(from_status: nil, to_status: "recebido", user: @user, created_at: Time.current)
      PaymentSimulator.new(order).process!
    end

    @cart.clear if errors.empty?
    Result.new(order, errors)
  end
end
