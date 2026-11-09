module Admin
  # US-017: relatório de vendas por período, produto e categoria
  class ReportsController < BaseController
    PERIODS = { "dia" => "Hoje", "semana" => "Esta semana", "mes" => "Este mês" }.freeze

    def index
      @period = PERIODS.key?(params[:periodo]) ? params[:periodo] : "mes"
      range = case @period
              when "dia" then Time.current.all_day
              when "semana" then Time.current.all_week
              else Time.current.all_month
              end
      orders = Order.counted_as_sale.where(created_at: range)
      @orders_count = orders.count
      @revenue = orders.sum(:total)
      @avg_ticket = @orders_count.zero? ? 0 : @revenue / @orders_count
      items = OrderItem.joins(:order, product: :category).merge(orders)
      @top_products = items.group("products.name").order(Arel.sql("SUM(order_items.quantity) DESC"))
                           .limit(10).pluck(Arel.sql("products.name, SUM(order_items.quantity), SUM(order_items.quantity * order_items.unit_price)"))
      @by_category = items.group("categories.name").order(Arel.sql("SUM(order_items.quantity * order_items.unit_price) DESC"))
                          .pluck(Arel.sql("categories.name, SUM(order_items.quantity), SUM(order_items.quantity * order_items.unit_price)"))
    end
  end
end
