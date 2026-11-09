class CheckoutsController < ApplicationController
  before_action :require_client!

  def new
    @lines = cart.lines
    return redirect_to(root_path, alert: "Seu carrinho está vazio.") if @lines.empty?
    load_summary
    @order = Order.new(delivery_date: next_delivery_day, delivery_period: "tarde", payment_method: "pix")
  end

  def create
    result = Checkout.new(user: current_user, cart: cart,
                          params: checkout_params.merge(coupon_code: session[:coupon_code])).call
    if result.success?
      session.delete(:coupon_code)
      redirect_to order_path(result.order), notice: "Pedido #{result.order.number} realizado com sucesso!"
    else
      @lines = cart.lines
      load_summary
      @order = Order.new(checkout_params.except(:address_id))
      @selected_address_id = checkout_params[:address_id].to_i
      flash.now[:alert] = result.errors.join(" ")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def checkout_params
    params.require(:order).permit(:address_id, :payment_method, :installments, :delivery_date, :delivery_period)
  end

  def load_summary
    @addresses = current_user.addresses.order(created_at: :desc)
    @selected_address_id ||= @addresses.first&.id
    @coupon = Coupon.find_by(code: session[:coupon_code]) if session[:coupon_code]
    @subtotal = @lines.sum(&:total)
    @discount = @coupon&.usable? ? @coupon.discount_for(@subtotal) : 0
    @shipping_by_address = @addresses.to_h { |a| [ a.id, Shipping.price_for(a.cep) ] }
  end

  def next_delivery_day
    date = Date.tomorrow
    date += 1 until Order.delivery_day?(date)
    date
  end
end
