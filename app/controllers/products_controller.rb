class ProductsController < ApplicationController
  def index
    @categories = Category.all
    @query = params[:q].to_s.strip
    @products = Product.available.includes(:category).search(@query)
    @products = @products.where(category_id: params[:categoria]) if params[:categoria].present?
    @products = @products.sorted(params[:ordem])
    # CA US-006#2: sem resultados, sugere produtos similares (mais vendidos)
    @suggestions = Product.available.sorted("populares").limit(3) if @products.empty?
  end

  def show
    @product = Product.available.find_by(id: params[:id])
    return redirect_to(root_path, alert: "Cupcake indisponível no momento.") unless @product
    @reviews = @product.reviews.approved.includes(:user).order(created_at: :desc)
    @related = Product.available.includes(:category).where.not(id: @product.id).sorted("populares").limit(3)
  end
end
