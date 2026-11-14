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

    def deactivate
      user = User.staff.find(params[:id])
      return redirect_to(admin_users_path, alert: "Você não pode desativar a própria conta.") if user == current_user
      user.update_columns(active: false)
      redirect_to admin_users_path, notice: "#{user.name} foi desativado(a) e não consegue mais entrar no painel."
    end

    def reactivate
      user = User.staff.find(params[:id])
      user.update_columns(active: true)
      redirect_to admin_users_path, notice: "#{user.name} foi reativado(a)."
    end
  end
end
