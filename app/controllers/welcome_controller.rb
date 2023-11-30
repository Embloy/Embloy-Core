class WelcomeController < ApplicationController
  require "json"
  skip_before_action :auth_prototype, only: [:privacy_policy, :help, :terms_of_service]

  def index
    if Current.user
      # flash.now[:notice] = "Logged in as #{Current.user.email}"
    else
      # flash.now[:alert] = "Currently not logged in!"
    end
  end

  def about
  end

  def privacy_policy
  end

  def api
  end

  def apidoc
    render json: File.read('app/views/welcome/apidoc.json')
  end

  def faq
  end

  def cookies
  end

  def help
  end

  def terms_of_service

  end

end
