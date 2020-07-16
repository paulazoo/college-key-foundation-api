class AccountsController < ApplicationController
  before_action :authenticate_user, only: %i[show]
  before_action :set_user, only: %i[show]
  before_action :authorize_user, only: %i[show]

  # GET /login
  def login
    decoded_hash = decoded_token
    logger.debug(decoded_hash)
    if decoded_hash && !decoded_hash.empty?
      google_id = decoded_hash[0]['sub']
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
          google_id: google_id
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

  private

  def account_params
    params.permit(:image_url, :bio, :display_name)
  end

  def set_account
    @account = Account.find(params[:account_id])
  end

  def authorize_account
    render(json: { errors: 'Not the correct account!' }, status: :unauthorized) if current_account != @account
  end

end
