class AccountsController < ApplicationController
  before_action :authenticate_account, only: %i[show update index master_update]
  before_action :set_account, only: %i[show update events]
  before_action :authorize_account, only: %i[show update index]

  # GET /login
  def login
    decoded_hash = decoded_token
    logger.debug(decoded_hash)
    if decoded_hash && !decoded_hash.empty?
      account_id = decoded_hash[0]['sub']
      email = decoded_hash[0]['email']
      name = decoded_hash[0]['name']
      given_name = decoded_hash[0]['given_name']
      family_name = decoded_hash[0]['family_name']
      image_url = decoded_hash[0]['picture']

      @account = Account.find_by(email: email)

      if !@account.blank?
        @account.update(
          name: name,
          image_url: image_url,
          given_name: given_name,
          family_name: family_name,
          google_id: account_id,
        )

        if @account.save
          Analytics.track(
            user_id: @account.id.to_s,
            event: 'Logged in',
            properties: { role: @account.user_type.to_s },
            context: { ip: request.remote_ip }
          )

          if @account.user_type == 'Mentor'
            render(json: { message: 'Logged in successfully!', account: @account, user: @account.user.as_json(include: [mentees: { include: :account }]) }, status: :ok)
          elsif @account.user_type == 'Mentee'
            render(json: { message: 'Logged in successfully!', account: @account, user: @account.user.as_json(include: [mentor: { include: :account }]) }, status: :ok)
          end

        else
          render(json: { errors: @account.errors })
        end

      else
        render(json: { message: 'You are not a mentor or mentee!' }, status: :ok)
      end

    else
      render(json: {}, status: :unauthorized)
    end
  end

  # GET /accounts
  def index
    if is_master
      @accounts = Account.all
      render(json: @accounts.to_json(include: :user))
    else
      render(json: { message: 'You are not master' }, status: :unauthorized)
    end
  end

  # GET /accounts/:id
  def show
    render(json: { errors: 'Not the correct account!' }, status: :unauthorized) if (current_account != @account && !is_master)

    if @account.user_type == 'Mentor'
      render(json: { account: @account, user: @account.user.as_json(include: [mentees: { include: :account }]) }, status: :ok)
    elsif @account.user_type == 'Mentee'
      render(json: { account: @account, user: @account.user.as_json(include: [mentor: { include: :account }]) }, status: :ok)
    end
  end

  # PUT /accounts/:id
  def update
    render(json: { errors: 'Not the correct account!' }, status: :unauthorized) if (current_account != @account)
 
    @account.email = account_params[:email] if account_params[:email]
    @account.phone = account_params[:phone] if account_params[:phone]
    @account.bio = account_params[:bio] if account_params[:bio]
    @account.display_name = account_params[:display_name] if account_params[:display_name]
    @account.grad_year = account_params[:grad_year] if account_params[:grad_year]
    @account.school = account_params[:school] if account_params[:school]
    @account.image_url = account_params[:image_url] if account_params[:image_url]

    if @account.save
      render(json: @account, status: :ok)
    else
      render(json: @account.errors, status: :unprocessable_entity)
    end
  end

  # PUT /accounts/master_update
  def master_update
    render(json: { message: 'You are not master' }, status: :unauthorized) unless is_master

    other_account = Account.find(account_params[:other_account_id])

    other_account.email = account_params[:email] if account_params[:email]
    other_account.phone = account_params[:phone] if account_params[:phone]
    other_account.bio = account_params[:bio] if account_params[:bio]
    other_account.display_name = account_params[:display_name] if account_params[:display_name]
    other_account.grad_year = account_params[:grad_year] if account_params[:grad_year]
    other_account.school = account_params[:school] if account_params[:school]
    other_account.image_url = account_params[:image_url] if account_params[:image_url]

    if other_account.save
      render(json: other_account, status: :ok)
    else
      render(json: other_account.errors, status: :unprocessable_entity)
    end
  end

  # GET /accounts/:id/events
  def events
    public_events = Event.where(kind: 'open')
    fellows_only_events = Event.where(kind: 'fellows_only')
    invited_events = @account.invited_events

    @events = public_events + fellows_only_events + invited_events

    @events.each do |event|
      event.current_account = current_account
    end

    render(json: @events.to_json(methods: [:account_registration]), status: :ok)
  end

  # POST /accounts/:id/mail
  def mail
    AccountMailer.welcome_email().deliver_later

    render(json: { message: 'Email sent!' })
  end

  private

  def account_params
    params.permit(:image_url, :bio, :display_name, :phone, :school, :grad_year, :email, \
      :other_account_id)
  end

  def set_account
    @account = Account.find(params[:id])
  end

  def authorize_account
    render(json: { errors: 'Not the correct account!' }, status: :unauthorized) if current_account != @account
  end

end
