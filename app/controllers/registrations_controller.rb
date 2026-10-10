class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params.require(:user).permit(:name, :email_address, :password))
      if @user.save
        start_new_session_for @user
        redirect_to root_path, notice: "Welcome, #{@user.name}!"
      else
        render :new, status: :unprocessable_entity
      end
  end
end
  
  