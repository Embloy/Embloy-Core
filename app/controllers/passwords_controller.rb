class PasswordsController < ApplicationController
  before_action :require_user_logged_in
  skip_before_action :auth_prototype

  def edit; end

  def update
    if Current.user.update(password_params) && !password_params[:password].nil? && !password_params[:password].blank?
      redirect_to root_path, notice: 'Password Updated'
    else
      flash[:alert] = "Changes could not be saved"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end