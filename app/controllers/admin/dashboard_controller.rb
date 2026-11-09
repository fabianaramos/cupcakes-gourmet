module Admin
  class DashboardController < BaseController
    def index
      @pending_orders = Order.active.count
      @today_sales = Order.counted_as_sale.where(created_at: Time.current.all_day).sum(:total)
      @low_stock = Product.where(active: true).low_stock.order(:stock) # CA US-015#3: alerta de estoque mínimo
      @pending_reviews = Review.pending.count
      @pending_admins = User.pending_approval.count
      @locked_admins = User.staff.where("locked_until > ?", Time.current).count
      @latest_orders = Order.recent.includes(:user).limit(5)
    end
  end
end
