class ApplicationsController < ApplicationController
  before_action :require_user_logged_in
  before_action :set_job
  layout 'job_applic_layout'

  def index
    @job = Job.find(params[:job_id])
    require_user_be_owner
    @applications = @job.applications.includes(:user).all
  end

  def attachment
    ApplicationAttachment.find_by(user_id: user_id, job_id: job_id)
  end

  def show
    require_user_be_owner
    redirect_back(fallback_location: root_path)
    # @job = Job.find(params[:job_id])
    # @application = @job.applications
  end

  def new
    require_user_logged_in
    @job = Job.find(params[:job_id])
    @application = Application.new
  end

  def create
    if require_user_logged_in
      @job = Job.find(params[:job_id])
      application_attachment = ""
      if params[:application].present? && params[:application][:attachment_attributes].present? && params[:application][:attachment_attributes][:cv].present?
        begin
          application_attachment = ApplicationAttachment.create!(
            user_id: Current.user.id.to_i,
            job_id: params[:job_id].to_i
          )
          application_attachment.cv.attach(params[:application][:attachment_attributes][:cv])
        rescue ActiveRecord::RecordInvalid
          application_attachment.destroy!
          flash[:alert] = "Application could not be submitted due to invalid file attachment"
          render :new, status: :unprocessable_entity, alert: "Application could not be submitted due to invalid file attachment"
        end
      end
      if application_attachment == "" || application_attachment.save
        begin
          @application = Application.create(
            user_id: Current.user.id.to_i,
            job_id: params[:job_id].to_i,
            application_text: application_params[:application_text],
            application_documents: application_params[:application_documents],
            created_at: Time.now,
            updated_at: Time.now,
            response: "No response yet..."
          )
        rescue ActiveRecord::RecordInvalid
          if application_attachment != ""
            application_attachment.destroy
          end
          flash[:alert] = "Application could not be submitted due to invalid input"
          render :new, status: :unprocessable_entity
        end
        @application.user = User.find(Current.user.id.to_i)
        @application.job = @job
        if @application.save
          redirect_to job_path(@job), notice: 'Application has been submitted'
        else
          if application_attachment != ""
            application_attachment.destroy
          end
          flash[:alert] = "Application could not be submitted due to issue with application"
          render :new, status: :unprocessable_entity
        end
      else
        if application_attachment != ""
          application_attachment.destroy
        end
        flash[:alert] = "Application could not be submitted due to issue with application attachment"
        render :new, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @job = Job.find(params[:job_id])
    if require_user_be_owner
      redirect_to job_path(@job), alert: 'Not allowed!' if Current.user.id != @job.user_id
      @application = @job.applications.find(params[:user_id])
      @application.destroy
      redirect_to job_path(@job), status: :see_other
    end
  end

  def accept
    @job = Job.find(params[:job_id])
    if require_user_be_owner
      application = @job.applications.where(user_id: params[:application_id]).first
      application.accept(application_params[:response])
      redirect_to job_path(@job), status: :see_other, notice: 'Application has been accepted'
    end
  end

  def reject
    @job = Job.find(params[:job_id])
    if require_user_be_owner
      application = @job.applications.where(user_id: params[:application_id]).first
      application.reject(application_params[:response])
      redirect_to job_applications_path(params[:job_id]), status: :see_other, notice: 'Application has been rejected'
    end
  end

  def reject_all
    @job = Job.find(params[:job_id])
    if require_user_be_owner
      @job.reject_all
      redirect_to job_path(@job), status: :see_other, notice: 'All Applications have been rejected'
    end
  end

  private

  def set_job
    @job = Job.find(params[:job_id])
  end

  def application_params
    params.require(:application).permit(:user_id, :application_text, :application_documents, :response, :cv)
  end
end
