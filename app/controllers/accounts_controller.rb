class AccountsController < ApplicationController
  before_action :authenticate_account, only: %i[show update index]
  before_action :set_account, only: %i[show update]
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
          google_id: account_id
        )

        if @account.save
          # context: { ip: request.remote_ip }
          render(json: { message: 'Logged in successfully!', account: @account, user: @account.user }, status: :ok)
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
    @accounts = Account.all
    json_response(@accounts)
  end

  # GET /accounts/:account_id
  def show
    render(json: { errors: 'Not the correct account!' }, status: :unauthorized) if current_account != @account

    render(json: @account.to_json)
  end

  # PUT /accounts/:account_id
  def update
    render(json: { errors: 'Not the correct account!' }, status: :unauthorized) if current_account != @account

    @account.bio = account_params[:bio] if account_params[:bio]
    @account.phone = account_params[:phone] if account_params[:phone]

    if @account.save
      render(json: @account, status: :ok)
    else
      render(json: @account.errors, status: :unprocessable_entity)
    end
  end

  private

  def account_params
    params.permit(:image_url, :bio, :display_name, :phone)
  end

  def set_account
    @account = Account.find(params[:account_id])
  end

  def authorize_account
    render(json: { errors: 'Not the correct account!' }, status: :unauthorized) if current_account != @account
  end

end
