# Carrinho guardado na sessão do navegador (US-007: persistente durante a sessão).
class Cart
  MAX_PER_ITEM = 50
  Line = Struct.new(:product, :quantity) do
    def total = product.price * quantity
  end

  def initialize(session)
    @session = session
    @session[:cart] ||= {}
  end

  def raw = @session[:cart]

  def add(product, quantity = 1)
    current = raw[product.id.to_s].to_i
    set(product, current + quantity.to_i)
  end

  # Retorna a quantidade efetivamente gravada (limitada a 1..50 e ao estoque).
  def set(product, quantity)
    qty = quantity.to_i.clamp(1, [ MAX_PER_ITEM, product.stock ].min.clamp(1, MAX_PER_ITEM))
    raw[product.id.to_s] = qty
    qty
  end

  def remove(product_id) = raw.delete(product_id.to_s)
  def clear = @session[:cart] = {}
  def empty? = raw.empty?
  def count = raw.values.sum(&:to_i)

  def lines
    products = Product.where(id: raw.keys).index_by { |p| p.id.to_s }
    raw.filter_map do |id, qty|
      product = products[id]
      if product.nil? || !product.available?
        raw.delete(id)
        next
      end
      Line.new(product, qty.to_i)
    end
  end

  def subtotal = lines.sum(&:total)
end
