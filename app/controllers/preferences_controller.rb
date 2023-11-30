class PreferencesController < ApplicationController
  before_action :require_user_logged_in

  def update
    # TODO: Fix null pointer
    @user = Current.user
    @preferences = Current.user.preferences

    interests = params[:interests]
    experience = params[:experience]
    degree = params[:degree]
    num_jobs_done = params[:num_jobs_done]
    gender = params[:gender]
    spontaneity = params[:spontaneity]
    # job_type = { "1": params[:job_type_1], "2": params[:job_type_2], "3": params[:job_type_3] }
    # TODO: Add option to select job_types in view
    job_types = { "1": 0.0, "2": 0.0, "3": 0.0 }
    key_skills = params[:key_skills]
    salary_range = [params[:salary_range_min], params[:salary_range_max]]
    cv_url = params[:cvupload]
    if !@preferences.nil? && @preferences.update!(
      interests: interests,
      experience: experience,
      degree: degree,
      num_jobs_done: num_jobs_done,
      gender: gender,
      spontaneity: spontaneity,
      job_types: job_types,
      key_skills: key_skills,
      salary_range: salary_range,
      cv_url: cv_url,
    )
      # if !@preferences.nil? && @preferences.update(spontaneity: params[:spontaneity]) && @preferences.update(job_type: job_type)
      redirect_to @user, notice: "Updated preferences"
    else
      flash[:alert] = "Could not save preferences"
      render :'user/preferences', status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:preferences).permit(:job_type_1, :job_type_2, :job_type_3, :spontaneity, :txtEmpPhone)
  end

end
