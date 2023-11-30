class PasswordResetsController < ApplicationController
  skip_before_action :auth_prototype

  def new; end

  def create
    if params[:email].present?
      @user = User.find_by(email: params[:email])
      if @user.present?
        # send mail
        PasswordMailer.with(user: @user).reset.deliver_later
      end
      redirect_to root_path, notice: 'Please check your email to reset the password'
    else
      flash[:alert] = "Bad request, email missing"
      render :'welcome/help', status: :bad_request
    end
  end

  def edit
    @user = User.find_signed!(params[:token], purpose: 'password_reset')
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "User does not exist"
    render 'welcome/help', status: :not_found
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    flash[:alert] = "Token has either expired, has a purpose mismatch, is for another record, or has been tampered with"
    render 'welcome/help', status: :bad_request
  end

  def update
    begin
      @user = User.find_signed!(params[:token], purpose: 'password_reset')
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "User does not exist"
      render 'welcome/help', status: :not_found
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      flash[:alert] = "Token has either expired, has a purpose mismatch, is for another record, or has been tampered with"
      render 'welcome/help', status: :bad_request
    end

    if @user.update(password_params)
      redirect_to sign_in_path, notice: 'Your password was reset successfully. Please sign in'
    else
      flash[:alert] = "Changes could not be saved"
      render 'welcome/help', status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
