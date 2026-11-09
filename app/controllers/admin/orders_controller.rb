module Admin
  class OrdersController < BaseController
    before_action :set_order, only: %i[show advance cancel]

    def index
      @status = params[:status].presence
      scope = Order.recent.includes(:user)
      scope = @status ? scope.where(status: @status) : scope.active
      @orders = paginate(scope)
    end

    def show
      @items = @order.order_items.includes(:product)
    end

    def advance
      @order.advance!(by: current_user)
      redirect_back fallback_location: admin_order_path(@order), notice: "Pedido #{@order.number}: #{@order.status_label}."
    end

    def cancel
      @order.cancel!(by: current_user)
      redirect_to admin_order_path(@order), notice: "Pedido cancelado e estoque devolvido."
    end

    private

    def set_order = @order = Order.find(params[:id])
  end
end
