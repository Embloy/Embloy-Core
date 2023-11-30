class ReviewsController < ApplicationController
  layout 'application'

  def index
    if require_user_be_owner
      @reviews = @user.reviews.all
    end
  end

  def new
    require_user_logged_in
    @review = Review.new
  end

  def create
    if require_user_logged_in
      if @review.save
        redirect_to @review
      else
        flash[:alert] = "Review has not been created"
        render :new, status: :unprocessable_entity
      end

    end
  end

  def application_params
    params.require(:review).permit(:rating, :message, :application_documents)
  end
end
