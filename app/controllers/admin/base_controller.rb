module Admin
  class BaseController < ApplicationController
    layout "admin"
    before_action :require_staff!

    PER_PAGE = 20

    private

    def require_staff!
      return if current_user&.staff? && current_user.approved?
      redirect_to admin_login_path, alert: "Acesso restrito ao painel administrativo."
    end

    def require_superadmin!
      redirect_to admin_root_path, alert: "Apenas o superadministrador pode fazer isso." unless current_user.superadmin?
    end

    def paginate(scope)
      @page = [ params[:page].to_i, 1 ].max
      @total_pages = [ (scope.count / PER_PAGE.to_f).ceil, 1 ].max
      scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    end
  end
end
