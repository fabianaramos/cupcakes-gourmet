class AddressesController < ApplicationController
  before_action :require_client!

  def new
    @address = current_user.addresses.build
  end

  def create
    @address = current_user.addresses.build(params.require(:address).permit(:cep, :street, :number, :complement, :neighborhood, :city, :state))
    if @address.save
      redirect_to checkout_path, notice: "Endereço cadastrado."
    else
      render :new, status: :unprocessable_entity
    end
  end
end
