class ApplicationController < ActionController::
  include Response
  include ExceptionHandler
  # include Knock::Authenticable

  private

  def auth_header
    request.headers['Authorization']
  end

  def decoded_token
    if auth_header
      token = auth_header.split(' ')[1]
      begin
        JWT.decode(token, nil, false)
      rescue JWT::DecodeError
        []
      end
    end
  end

  def current_user
    decoded_hash = decoded_token
    if decoded_hash && !decoded_hash.empty?
      email = decoded_hash[0]['email']
      @account = Account.find_by(email: email)
    end
  end

  def logged_in?
    !!current_account
  end

  def authenticate_account
    render(json: { message: 'Please Login' }, status: :unauthorized) unless logged_in?
  end

  def is_mentor
    (current_account.user_type == 'Mentor')
  end

  def is_master
    (current_account.email == 'paulazhu@college.harvard.edu')
  end
end
