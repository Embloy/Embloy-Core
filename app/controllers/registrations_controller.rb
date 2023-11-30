class RegistrationsController < ApplicationController
  skip_before_action :auth_prototype

  def new
    @user = User.new
  end

  def find_coordinates
    if !user_params[:country_code].nil? && !user_params[:postal_code].nil? && !user_params[:city].nil? && !user_params[:address].nil?
      @user[:longitude] = 0.0
      @user[:latitude] = 0.0
    end
  end

  def create
    @user = User.new(user_params)
    find_coordinates
    if @user.save
      WelcomeMailer.with(user: @user).welcome_email.deliver_later
      session[:user_id] = @user.id
      redirect_to root_path, notice: 'Successfully created account. Check your emails to verify your account.'
    else
      flash[:alert] = "Could not save user"
      render :new, status: :unprocessable_entity
    end
  end

  def verify_account
    begin
      @user = User.find_signed!(params[:token], purpose: 'verify_account')
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "User does not exist"
      render :new, status: :not_found
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      flash[:alert] = "Token has either expired, has a purpose mismatch, is for another record, or has been tampered with"
      render :new, status: :unprocessable_entity
    end
    # TODO: Change to "verified" when opening prototype to public.
    # TODO: @cb: check activity_status
    if @user.update(user_role: "spectator") && @user.update(activity_status: 1)
      WelcomeMailer.with(user: @user).notify_team.deliver_later
      redirect_to sign_in_path, notice: 'Your account was verified successfully.'
    else
      flash[:alert] = "Could not verify user"
      render :new, status: :unprocessable_entity
    end
  end

  def activate_account
    begin
      @user = User.find_signed!(params[:token], purpose: 'activate_account')
    rescue ActiveRecord::RecordNotFound
      redirect_to activate_account_path, status: :not_found, alert: "User does not exist"
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to activate_account_path, status: :unprocessable_entity, alert: "Token has either expired, has a purpose mismatch, is for another record, or has been tampered with"
    end

    if @user.update(user_role: "verified")
      redirect_to sign_in_path, notice: 'Account was verified successfully.'
    else
      redirect_to sign_in_path, status: :unprocessable_entity, alert: "Could not activate user"
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation, :longitude, :latitude, :country_code, :city, :postal_code, :address, :date_of_birth, :password_repeat, :application_notifications)
  end
end
