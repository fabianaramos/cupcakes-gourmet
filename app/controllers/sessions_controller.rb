class SessionsController < ApplicationController
  def new; end

  def create
    user = User.clientes.find_by(email: params[:email].to_s.strip.downcase)
    if user&.locked?
      flash.now[:alert] = "Conta bloqueada por excesso de tentativas. Tente novamente em alguns minutos."
      return render(:new, status: :unprocessable_entity)
    end

    if user&.authenticate(params[:password])
      user.register_successful_login!
      sign_in(user)
      redirect_to(session.delete(:return_to) || root_path, notice: "Olá, #{user.name.split.first}!")
    else
      user&.register_failed_login!
      flash.now[:alert] = user&.locked? ? "Conta bloqueada por 15 minutos após 5 tentativas inválidas." : "E-mail ou senha incorretos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out
    redirect_to login_path, notice: "Você saiu da sua conta."
  end
end
