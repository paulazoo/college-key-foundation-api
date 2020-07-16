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
      render(json: { message: 'Account already exists!' })
    end
  end


  private

  def set_mentee
    @mentee = Mentee.find(params[:id])
  end

  def mentee_params
    params.permit([:email])
  end
end
