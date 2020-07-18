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
        Analytics.identify(
          user_id: @account.id.to_s,
          traits: {
            rols: @account.user_type.to_s,
            account_id: @account.id.to_s,
            email: @account.email.to_s,
            name: @account.name.to_s,
            google_id: @account.google_id.to_s,
          },
        )
        
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
