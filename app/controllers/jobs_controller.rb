require_relative '../../lib/feed_generator.rb'

class JobsController < ApplicationController
  before_action :require_user_logged_in, except: %w[index show find parse_inputs map update_jobs]
  layout 'job_applic_layout', :only => "edit"

  # Creates feed based on current user's preferences (if available); if the current user is not verified yet or
  # isn't logged in, his feed consists of random jobs (limit 100)
  def index
    # TODO: Get User Coordinates (currently saved directly as latitude, longitude in DB)
    unless Current.user.nil?
      lat = Current.user.latitude
      lng = Current.user.longitude
    end

    # Slice jobs
    # jobs = JobSlicer.slice(Current.user, 30000, lat, lng)
    jobs = JobSlicer.fetch_feed(lat, lng)
    # jobs = Job.order('random()').limit(10)
    # jobs = Job.all.limit(10)
    # Call FG-API to rank jobs
    if !jobs.nil? && !jobs.empty?
      # TODO: Add pagination to feed / slicer @jobs = call_feed(jobs[params[:page]])

      @jobs = []
      call_feed(jobs).each do |j_id|
        @jobs << Job.find_by_job_id(j_id)
      end

    else
      render status: 204, json: { "message": "No jobs found!" }
    end
  end

  def map
    lat = params[:latitude]
    lng = params[:longitude]
    if (lat.nil? || lng.nil?) && !Current.user.nil? && !Current.user.longitude.nil? && !Current.user.latitude.nil?
      lat = Current.user.latitude
      lng = Current.user.longitude
      @jobs = JobSlicer.fetch(lat, lng)
    else
      @jobs = Job.order('random()').limit(100)
    end
  end

  def update_jobs
    lat = params[:latitude]
    lng = params[:longitude]
    if (lat.nil? || lng.nil?) && !Current.user.nil? && !Current.user.longitude.nil? && !Current.user.latitude.nil?
      lat = Current.user.latitude
      lng = Current.user.longitude
    end
    @jobs = JobSlicer.fetch_map(lat, lng)
    respond_to do |format|
      format.json { render json: @jobs.to_json(except: [:image_url, :description]) }
    end
  end

  def show
    @job = Job.find(params[:id])
    @owner = owner
    if Current.user
      @application = Application.find_by(user_id: Current.user.id, job_id: params[:id])
      unless owner
        aa = ApplicationAttachment.find_by(user_id: Current.user.id, job_id: params[:id])
        unless aa.nil?
          @cv = aa.cv
        end
        mark_notifications_as_read
      end
    end
  end

  def new
    @job = Job.new
    @job.currency = "EUR"
    @categories_list = JSON.parse(File.read(Rails.root.join('app/helpers', 'job_types.json'))).keys
    @allowed_cv_formats = %w[.pdf .docx .txt .xml]
    @editing = false
  end

  def create
    params[:job][:allowed_cv_format].reject!(&:empty?)

    @job = Job.new(job_params)
    @categories_list = JSON.parse(File.read(Rails.root.join('app/helpers', 'job_types.json'))).keys
    @allowed_cv_formats = %w[.pdf .docx .txt .xml]
    @editing = false
    @job.currency = "EUR"

    if params[:job][:allowed_cv_format].empty? || params[:job][:cv_required] == 0
      params[:job][:cv_required] = false
    end

    @job.currency = "EUR"
    @job.user_id = Current.user.id

    job_types_file = File.read(Rails.root.join('app/helpers', 'job_types.json'))
    job_types = JSON.parse(job_types_file)
    job_type = @job.job_type
    @job.job_type_value = job_types[job_type]

    if @job.save && @job.update(geocode(@job))
      @job.image_url.attach(params[:job][:image_url]) if params[:job][:image_url].present?
      SpatialJobValue.update_job_value(@job)
      redirect_to @job, notice: "Created new job"
    else
      flash[:alert] = "Job has not been created"
      render :new, status: :unprocessable_entity, alert: "Job has not been created"
    end
  end

  def edit
    @job = Job.find(params[:id])
    @allowed_cv_formats = %w[.pdf .docx .txt .xml]
    require_user_be_owner
    @categories_list = JSON.parse(File.read(Rails.root.join('app/helpers', 'job_types.json'))).keys
    @editing = true
  end

  def update
    @job = Job.find(params[:id])
    @categories_list = JSON.parse(File.read(Rails.root.join('app/helpers', 'job_types.json'))).keys
    @allowed_cv_formats = %w[.pdf .docx .txt .xml]
    require_user_be_owner
    params[:job][:allowed_cv_format].reject!(&:empty?)

    if params[:job][:allowed_cv_format].empty? || params[:job][:cv_required] == 0
      params[:job][:cv_required] = false
    end

    if @job.update(job_params) && @job.update(geocode(@job))
      @job.image_url.attach(params[:job][:image_url]) if params[:job][:image_url].present?
      SpatialJobValue.update_job_value(@job)
      redirect_to @job
    else
      flash[:alert] = "Job has not been created"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @job = Job.find(params[:id])
    require_user_be_owner
    if @job.destroy
      redirect_to own_jobs_path, status: :see_other, notice: "Job successfully deleted"
    else
      flash[:alert] = "Job has not been deleted"
      render :show, status: :unprocessable_entity
    end
  end

  def remove_image
    @job = Job.find(params[:id])
    @job.image_url.purge if @job.image_url.attached?
    redirect_to @job, notice: "Job image has been removed"
  end

  def find
    @categories_list = JSON.parse(File.read(Rails.root.join('app/helpers', 'job_types.json'))).keys

    # @jobs = Job.search_for(params[:query])
    @jobs = Job.includes([:user]).includes(image_url_attachment: :blob).where("title ILIKE :query OR description ILIKE :query OR position ILIKE :query OR job_type ILIKE :query OR key_skills ILIKE :query OR address ILIKE :query OR city ILIKE :query OR postal_code ILIKE :query OR start_slot::text ILIKE :query", query: "%#{params[:query]}%")
               .page(params[:page])

    if @jobs.nil? || @jobs.empty?
      @jobs = Job.includes([:user]).includes(image_url_attachment: :blob).all
    end

    unless params[:job_type].nil? || params[:job_type].blank?
      @jobs = @jobs.includes([:user]).includes(image_url_attachment: :blob).where(job_type: params[:job_type])
    end

    case params[:sort_by]
    when "salary_asc"
      @jobs = @jobs.includes([:user]).includes(image_url_attachment: :blob).order(salary: :asc)
    when "salary_desc"
      @jobs = @jobs.includes([:user]).includes(image_url_attachment: :blob).order(salary: :desc)
    when "date_asc"
      @jobs = @jobs.includes([:user]).includes(image_url_attachment: :blob).order(created_at: :asc)
    when "date_desc"
      @jobs = @jobs.includes([:user]).includes(image_url_attachment: :blob).order(created_at: :desc)
    end

    @jobs = @jobs.page(params[:page]).per(24)
  end

  private

  # Method to communicate with the FG-API by sending a POST-request to tbd
  def call_feed(jobs)
    url = URI.parse("https://embloy-fg-api.onrender.com/feed")
    # url = URI.parse("http://localhost:8080/feed")
    if !Current.user.nil? && !Current.user.preferences.nil?
      request_body = "{\"pref\": #{Current.user.preferences.to_json}, \"slice\": #{jobs.to_json(except: [:image_url, :description])}}"
    else
      request_body = "{\"slice\": #{jobs.to_json(except: [:image_url, :description])}}"
    end
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Post.new(url)
    request.basic_auth('FG', 'pw')
    request.body = request_body
    request["Content-Type"] = "application/json"
    response = http.request(request)

    if response.code == '200'
      feed_json = JSON.parse(response.body)
      res = []
      feed_json.each do |job_hash|
        # puts job_hash["job_id"]
        res << job_hash["job_id"]
        # @jobs << Job.new(job_hash)
      end
      res
    end
  end

  def geocode(job)
    begin
      latitude = job.latitude
      longitude = job.longitude
      result = Geocoder.search("#{latitude},#{longitude}").first
      country_code = result.country_code
      postal_code = result.postal_code
      city = result.city
      address = result.address
      { country_code: country_code, postal_code: postal_code, city: city, address: address }
    rescue
      {}
    end
  end

  def job_params
    params.require(:job).permit(
      :title, :description, :content, :job_notifications, :start_slot,
      :notify, :status, :user_id, :longitude, :latitude, :job_type,
      :position, :currency, :salary, :key_skills, :duration, :image_url, :cv_required,
      :allowed_cv_format => []
    )
  end

  def location_params
    params.require(:job).permit(:country_code, :postal_code, :city, :address)
  end

  def mark_notifications_as_read
    if Current.user
      notifications_to_mark_as_read = @job.notifications_as_job.where(recipient: Current.user)
      notifications_to_mark_as_read.update_all(read_at: Time.zone.now)
    end
  end
end
