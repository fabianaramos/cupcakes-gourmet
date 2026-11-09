module Admin
  class CouponsController < BaseController
    before_action :set_coupon, only: %i[edit update destroy]

    def index
      @coupons = Coupon.order(created_at: :desc)
      @coupons = @coupons.where("code LIKE ?", "%#{Coupon.sanitize_sql_like(params[:q].upcase)}%") if params[:q].present?
      @coupons = @coupons.where(active: params[:ativo] == "1") if params[:ativo].present?
    end

    def new
      @coupon = Coupon.new(kind: "percentual", valid_until: 30.days.from_now.to_date, usage_limit: 100)
    end

    def create
      @coupon = Coupon.new(coupon_params)
      if @coupon.save
        redirect_to admin_coupons_path, notice: "Cupom criado."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @coupon.update(coupon_params)
        redirect_to admin_coupons_path, notice: "Cupom atualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @coupon.update(active: false)
      redirect_to admin_coupons_path, notice: "Cupom desativado."
    end

    private

    def set_coupon = @coupon = Coupon.find(params[:id])
    def coupon_params = params.require(:coupon).permit(:code, :kind, :value, :valid_until, :usage_limit, :active)
  end
end
