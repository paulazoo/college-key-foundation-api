class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
  # include ::ActionController::Cookies
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

  def current_account
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
    (current_account.email == 'paulazhu@college.harvard.edu' || current_account.email == 'collegekeyfoundation@gmail.com')
  end
end
