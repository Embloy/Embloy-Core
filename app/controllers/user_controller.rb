class UserController < ApplicationController
  before_action :require_user_logged_in

  def index
    @user = Current.user
    @user.update(view_count: @user.view_count + 1)
    # @jobs = @user.jobs.includes(:rich_text_body).order(created_at: :desc)
    @jobs = @user.jobs.order(created_at: :desc)
    @total_job_views = 0

    @jobs.each do |job|
      @total_job_views += job.view_count
    end
  end

  def settings
    @user = Current.user
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    if @user.update(user_params)
      @user.image_url.attach(params[:user][:image_url]) if params[:user][:image_url].present?
      redirect_to @user, notice: "Updated profile"
    else
      flash[:alert] = "Could not save changes"
      render :index, status: :unprocessable_entity
    end
  rescue IsoCountryCodes::UnknownCodeError
    flash[:alert] = "#{user_params[:country_code]} is not a valid ISO country code"
    render :index, status: :bad_request
  end

  def update_location
    if params[:latitude].present? && params[:longitude].present?
      Current.user.update(latitude: params[:latitude], longitude: params[:longitude])
    elsif params[:location_denied]
      redirect_to root_path, alert: "Unable to update location as location access was denied"
    end
  end

  def destroy
    @user = Current.user
    if @user.destroy
      redirect_to root_path, status: :see_other, notice: "Account successfully deleted"
    else
      flash[:alert] = 'Account could not be deleted'
      render :index, status: :unprocessable_entity
    end
  end

  def remove_image
    @user = Current.user
    @user.image_url.purge if @user.image_url.attached?
    redirect_to profile_index_path(@user), notice: "Profile image has been removed"
  end

  def preferences
    @user = Current.user
    if @user.preferences.nil?
      @user.create_preferences
      unless @user.save
        flash[:alert] = 'Preferences could not be saved'
        render :preferences, status: :unprocessable_entity
      end
    end
    @preferences = Current.user.preferences
    @categories_list = JSON.parse(File.read(Rails.root.join('app/helpers', 'job_types.json'))).keys
  end

  def own_jobs
    # @jobs = @user.jobs.includes(:rich_text_body).order(created_at: :desc)
    @jobs = Current.user.jobs.order(created_at: :desc)
  end

  def own_applications
    # TODO: Optimize
    @applications = Application.includes(:user).all.where("user_id = #{Current.user.id}").order("updated_at DESC")
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :degree, :date_of_birth, :country_code, :city, :postal_code, :address, :twitter_url, :facebook_url, :linkedin_url, :instagram_url)
  end

end

