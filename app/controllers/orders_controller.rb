class OrdersController < ApplicationController
  before_action :require_client!
  before_action :set_order, only: %i[show cancel]

  def index
    @orders = current_user.orders.recent.includes(:order_items)
  end

  def show
    @items = @order.order_items.includes(:product)
    @reviewed_ids = @order.reviews.pluck(:product_id)
  end

  def cancel
    @order.cancel!(by: current_user)
    redirect_to order_path(@order), notice: ["Pedido cancelado.", @order.refund_message].compact.join(" ")
  end

  private

  def set_order
    @order = current_user.orders.find_by(id: params[:id])
    redirect_to orders_path, alert: "Pedido não encontrado." unless @order
  end
end
