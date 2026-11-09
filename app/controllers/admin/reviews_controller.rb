module Admin
  class ReviewsController < BaseController
    def index
      @reviews = Review.includes(:user, :product).order(approved: :asc, created_at: :desc)
    end

    def update
      Review.find(params[:id]).update!(approved: true)
      redirect_to admin_reviews_path, notice: "Avaliação publicada."
    end

    def destroy
      Review.find(params[:id]).destroy
      redirect_to admin_reviews_path, notice: "Avaliação removida."
    end
  end
end
