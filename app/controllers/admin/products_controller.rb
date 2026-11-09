module Admin
  class ProductsController < BaseController
    before_action :set_product, only: %i[edit update destroy stock]

    def index
      @products = Product.includes(:category).order(:name)
      @products = @products.search(params[:q]) if params[:q].present?
    end

    def new
      @product = Product.new(active: false, min_stock: 10)
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_products_path, notice: "Cupcake cadastrado#{' (inativo até ser publicado)' unless @product.active?}."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: "Cupcake atualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @product.destroy
        redirect_to admin_products_path, notice: "Cupcake excluído."
      else
        redirect_to admin_products_path, alert: "Não é possível excluir um cupcake que já foi vendido. Desative-o."
      end
    end

    # US-015: ajuste rápido de estoque
    def stock
      if @product.update(stock: params[:stock])
        msg = "Estoque de #{@product.name}: #{@product.stock} un."
        msg += " Atenção: abaixo do mínimo (#{@product.min_stock})." if @product.low_stock?
        redirect_to admin_products_path, notice: msg
      else
        redirect_to admin_products_path, alert: @product.errors.full_messages.join(" ")
      end
    end

    private

    def set_product = @product = Product.find(params[:id])

    def product_params
      params.require(:product).permit(:name, :description, :ingredients, :allergens, :price, :stock, :min_stock, :active, :image_url, :category_id)
    end
  end
end
