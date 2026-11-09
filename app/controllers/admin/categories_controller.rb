module Admin
  class CategoriesController < BaseController
    def index
      @categories = Category.all
      @category = Category.new
    end

    def create
      @category = Category.new(name: params.dig(:category, :name))
      if @category.save
        redirect_to admin_categories_path, notice: "Categoria criada."
      else
        @categories = Category.all
        render :index, status: :unprocessable_entity
      end
    end

    def destroy
      category = Category.find(params[:id])
      if category.destroy
        redirect_to admin_categories_path, notice: "Categoria excluída."
      else
        redirect_to admin_categories_path, alert: "Categoria possui cupcakes e não pode ser excluída."
      end
    end
  end
end
