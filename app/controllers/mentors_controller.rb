class MentorsController < ApplicationController
  before_action :authenticate_account, only: %i[create index]

  # GET menters
  def index
    if is_master
      @mentors = Mentor.all
      json_response(@mentors)
    else
      render(json: { message: 'You are not master' }, status: :unauthorized)
    end
  end

  # POST /mentors
  def create
    @account = Account.find_by(email: mentor_params[:email])

    if @account.blank?
      @mentor = Mentor.new()

      @mentor.account = Account.new(user: @mentor, email: mentor_params[:email])

      if @mentor.save
        Analytics.identify(
          user_id: @mentor.account.id.to_s,
          traits: {
            role: 'Mentor',
            account_id: @mentor.account.id.to_s,
            email: @mentor.account.email.to_s,
            name: @mentor.account.name.to_s,
            google_id: @mentor.account.google_id.to_s,
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
