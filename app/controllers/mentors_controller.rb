class MentorsController < ApplicationController
  before_action :authenticate_account, only: %i[create index]

  # GET menters
  def index
    @mentors = Mentor.all
    json_response(@mentors)
  end

  # POST /mentors
  def create
    @account = Account.find_by(email: mentor_params[:email])

    if @account.blank?
      @mentor = Mentor.new()

      @mentor.account = Account.new(user: @mentor, email: mentor_params[:email])

      if @mentor.save
        render(json: @mentor.to_json, status: :created)
      else
        render(json: @mentor.errors, status: :unprocessable_entity)
      end

    else
      render(json: { message: 'Account already exists!' })
    end
  end


  private

  def set_mentor
    @mentor = mentor.find(params[:id])
  end

  def mentor_params
    params.permit([:email])
  end
end
