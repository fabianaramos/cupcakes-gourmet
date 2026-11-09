module Admin
  # US-021: cadastro de administrador fica pendente até aprovação do superadministrador.
  class RegistrationsController < ApplicationController
    layout "admin"

    def new
      @user = User.new
    end

    def create
      @user = User.new(params.require(:user).permit(:name, :email, :password, :password_confirmation)
                             .merge(role: "admin", approved: false))
      if @user.save
        redirect_to admin_login_path, notice: "Cadastro enviado! Aguarde a aprovação do superadministrador."
      else
        render :new, status: :unprocessable_entity
      end
    end
  end
end
