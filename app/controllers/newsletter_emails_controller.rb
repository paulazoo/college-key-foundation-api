class NewsletterEmailsController < ApplicationController
  # GET newsletter_emails
  def index
    @newsletter_emails = NewsletterEmail.all
    json_response(@newsletter_emails)
  end

  # POST /newsletter_emails
  def create
    @newsletter_email = NewsletterEmail.find_or_create_by(email: newsletter_email_params[:email])

    render(json: @newsletter_email, status: :created)
  end


  private

  def set_newsletter_email
    @newsletter_email = NewsletterEmail.find(params[:id])
  end

  def newsletter_email_params
    params.permit([:email])
  end

end
