module Admin
  class UsersController < BaseController
    before_action :require_superadmin!

    def index
      @users = User.staff.order(:approved, :name)
    end

    def approve
      User.staff.find(params[:id]).update_columns(approved: true)
      redirect_to admin_users_path, notice: "Administrador aprovado."
    end

    def unlock
      User.staff.find(params[:id]).unlock!
      redirect_to admin_users_path, notice: "Conta desbloqueada."
    end
  end
end
