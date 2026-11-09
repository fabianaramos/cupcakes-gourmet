module Admin
  class SessionsController < ApplicationController
    layout "admin"

    def new; end

    def create
      user = User.staff.find_by(email: params[:email].to_s.strip.downcase)
      if user&.locked?
        flash.now[:alert] = "Conta bloqueada. O superadministrador foi notificado e precisa desbloqueá-la."
      elsif user&.authenticate(params[:password])
        unless user.approved?
          flash.now[:alert] = "Cadastro aguardando aprovação do superadministrador."
          return render(:new, status: :unprocessable_entity)
        end
        user.register_successful_login!
        sign_in(user)
        return redirect_to(admin_root_path, notice: "Bem-vindo(a) ao painel, #{user.name.split.first}.")
      else
        user&.register_failed_login!
        flash.now[:alert] = user&.locked? ? "Conta bloqueada após 3 tentativas. O superadministrador foi notificado." : "E-mail ou senha incorretos."
      end
      render :new, status: :unprocessable_entity
    end

    def destroy
      sign_out
      redirect_to admin_login_path, notice: "Sessão administrativa encerrada."
    end
  end
end
