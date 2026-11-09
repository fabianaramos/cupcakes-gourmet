class ReviewsController < ApplicationController
  before_action :require_client!

  def create
    order = current_user.orders.find_by(id: params[:order_id])
    return redirect_to(orders_path, alert: "Pedido não encontrado.") unless order
    review = order.reviews.build(params.require(:review).permit(:product_id, :rating, :comment).merge(user: current_user))
    if review.save
      redirect_to order_path(order), notice: "Obrigado! Sua avaliação será publicada após moderação."
    else
      redirect_to order_path(order), alert: review.errors.full_messages.join(" ")
    end
  end
end
