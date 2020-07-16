class MenteesController < ApplicationController

  # GET mentees
  def index
    @mentees = Mentee.all
    json_response(@mentees)
  end

  # POST /mentees
  def create
    @account = Account.find_by(email: mentee_params[:email])

    if @account.blank?
      @mentee = Mentee.new()

      @mentee.account = Account.new(user: @mentee, email: mentee_params[:email])

      if @mentee.save
        render(json: @mentee.to_json, status: :created)
      else
        render(json: @mentee.errors, status: :unprocessable_entity)
      end

    else
      render(json: { message: 'Account already exists' })
    end
  end

  # POST /mentees/match
  def match
    @mentee = Mentee.find(mentee_params[:mentee_id])
    render(json: { message: 'Mentee does not exist' }) if @mentee.blank?

    @mentor = Mentor.find(mentor_params[:mentor_id])
    render(json: { message: 'Mentor does not exist'}) if @mentor.blank?

    

    if @mentee.save && @mentor.save
      render(json: { mentee: @mentee, mentor: @mentor }, status: :created)
    else
      render(json: @mentee.errors, status: :unprocessable_entity)
    end
  end

  private

  def set_mentee
    @mentee = Mentee.find(params[:id])
  end

  def mentee_params
    params.permit([:email, :mentee_id, :mentor_id])
  end
end
