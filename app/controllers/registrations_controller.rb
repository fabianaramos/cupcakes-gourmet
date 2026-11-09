class RegistrationsController < ApplicationController
  def new
    @user = User.new
    @address = Address.new
  end

  def create
    @user = User.new(user_params.merge(role: "cliente"))
    @address = @user.addresses.build(address_params)
    if @user.save
      sign_in(@user)
      redirect_to(session.delete(:return_to) || root_path, notice: "Cadastro realizado! Bem-vindo(a), #{@user.name.split.first}.")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :cpf, :phone, :password, :password_confirmation)
  end

  def address_params
    params.require(:address).permit(:cep, :street, :number, :complement, :neighborhood, :city, :state)
  end
end
