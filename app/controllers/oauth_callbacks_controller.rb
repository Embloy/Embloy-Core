class OauthCallbacksController < ApplicationController
  skip_before_action :auth_prototype

  def github
    authenticate
    # TODO: FETCH ADDITIONAL METADATA
  end

  def google
    authenticate
    # TODO: FETCH ADDITIONAL METADATA
  end

  def auth
    request.env['omniauth.auth']
  end

  def authenticate
    if !auth.info.email.nil?
      user = User.find_by(email: auth.info.email)
      if user.present?
        # && user.authenticate(auth.credentials.token)
        session[:user_id] = user.id
        redirect_to root_path, notice: 'Logged in successfully'
      else
        @user = User.new(
          email: auth.info.email,
          password: SecureRandom.hex,
          first_name: auth.info.name.split[0],
          last_name: auth.info.name.split[1],
          image_url: auth.info.image
        )
        if @user.save
          WelcomeMailer.with(user: @user).welcome_email.deliver_later
          session[:user_id] = @user.id
          redirect_to root_path, notice: 'Successfully created account'
        else
          flash[:alert] = "Invalid email or password"
          render :new, status: :unprocessable_entity
        end
      end
    else
      flash[:alert] = "Invalid email or password"
      render :new, status: :bad_request
    end
  end
end
