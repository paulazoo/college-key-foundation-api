class MenteesController < ApplicationController
  before_action :authenticate_account, only: %i[create index match]
  before_action :set_mentee, only: %i[match]

  # GET mentees
  def index
    if is_master
      @mentees = Mentee.all
      render(json: @mentees.to_json(include: [:account, mentor: { include: :account }]))
    else
      render(json: { message: 'You are not master' }, status: :unauthorized)
    end
  end

  # POST /mentees
  def create
    @account = Account.find_by(email: mentee_params[:email])

    if @account.blank?
      @mentee = Mentee.new()

      @mentee.account = Account.new(user: @mentee, email: mentee_params[:email])

      if @mentee.save
        Analytics.identify(
          user_id: @mentee.account.id.to_s,
          traits: {
            role: 'Mentee',
            account_id: @mentee.account.id.to_s,
            email: mentee_params[:email],
          },
        )

        render(json: @mentee.to_json, status: :created)
      else
        render(json: @mentee.errors, status: :unprocessable_entity)
      end

    else
      render(json: { message: 'Account already exists' })
    end
  end

  # POST /mentees/:mentee_id/match
  def match
    @mentee = Mentee.find(mentee_params[:mentee_id])
    render(json: { message: 'Mentee does not exist' }) if @mentee.blank?

    @mentor = Mentor.find(mentee_params[:mentor_id])
    render(json: { message: 'Mentor does not exist'}) if @mentor.blank?

    @mentor.mentees << @mentee

    if @mentor.save
      render(json: { mentee: @mentee, mentor: @mentor }, status: :created)
    else
      render(json: @mentor.errors, status: :unprocessable_entity)
    end
  end

  # POST /mentees/batch
  def batch
    @account = Account.find_by(email: mentee_params[:email])

    if @account.blank?
      @mentee = Mentee.new()

      @mentee.account = Account.new(user: @mentee, email: mentee_params[:email])

      if @mentee.save
        Analytics.identify(
          user_id: @mentee.account.id.to_s,
          traits: {
            role: 'Mentee',
            account_id: @mentee.account.id.to_s,
            email: mentee_params[:email],
          },
        )

        render(json: @mentee.to_json, status: :created)
      else
        render(json: @mentee.errors, status: :unprocessable_entity)
      end

    else
      render(json: { message: 'Account already exists' })
    end
  end

  private

  def set_mentee
    @mentee = Mentee.find(params[:mentee_id])
  end

  def mentee_params
    params.permit([:email, :mentee_id, :mentor_id])
  end
end
