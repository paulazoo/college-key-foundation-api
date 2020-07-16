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

      @account = Account.where(email: email).first_or_initialize()

      # If before first logs, 
      # record is created but some props are null, 
      # so first_or_initialize alone won't update the record
      @account.update(
        name: name,
        image_url: image_url,
        given_name: given_name,
        family_name: family_name,
        google_id: google_id
      )

      if @account.save
        # context: { ip: request.remote_ip }
        render(json: @account.to_json, status: :ok)
      else
        render(json: { errors: @account.errors })
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
