class CartsController < ApplicationController
  def show
    @lines = cart.lines
    @coupon = Coupon.find_by(code: session[:coupon_code]) if session[:coupon_code]
    @subtotal = @lines.sum(&:total)
    @discount = @coupon&.usable? ? @coupon.discount_for(@subtotal) : 0
  end

  def add
    product = Product.available.find_by(id: params[:product_id])
    return redirect_back(fallback_location: root_path, alert: "Cupcake indisponível.") unless product
    requested = [ params[:quantity].to_i, 1 ].max
    before = cart.raw[product.id.to_s].to_i
    qty = cart.add(product, requested)
    msg = "#{product.name} adicionado ao carrinho."
    msg += " Quantidade ajustada para #{qty} (limite: estoque ou 50 unidades)." if qty < before + requested
    redirect_back fallback_location: cart_path, notice: msg
  end

  def update
    product = Product.find_by(id: params[:id])
    if product
      wanted = params[:quantity].to_i
      qty = cart.set(product, wanted)
      flash[:alert] = "Quantidade ajustada para #{qty} (mínimo 1, máximo 50 ou o estoque disponível)." if qty != wanted
    end
    redirect_to cart_path
  end

  def remove
    cart.remove(params[:id])
    session.delete(:coupon_code) if cart.empty?
    redirect_to cart_path, notice: "Item removido do carrinho."
  end

  def apply_coupon
    code = params[:code].to_s.strip.upcase
    coupon = Coupon.find_by(code: code)
    if code.blank?
      session.delete(:coupon_code)
      redirect_to cart_path, notice: "Cupom removido."
    elsif coupon.nil?
      redirect_to cart_path, alert: "Cupom inválido."
    elsif !coupon.usable?
      redirect_to cart_path, alert: coupon.unusable_reason
    else
      session[:coupon_code] = coupon.code # CA US-009#3: apenas um cupom por pedido
      redirect_to cart_path, notice: "Cupom #{coupon.code} aplicado (#{coupon.label})."
    end
  end
end
