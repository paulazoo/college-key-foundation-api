class NewsletterEmailsController < ApplicationController
  # GET newsletter_emails
  def index
    @newsletter_emails = NewsletterEmail.all
    json_response(@newsletter_emails)
  end

  # POST /newsletter_emails
  def create
    @email_newsletter= find_or_create_by(email: newsletter_email_params[:email])

    if @newsletter_email.save
      render(json: @newsletter_email.to_json, status: :created)
    else
      render(json: @newsletter_email.errors, status: :unprocessable_entity)
    end
  end


  private

  def set_newsletter_email
    @newsletter_email = NewsletterEmail.find(params[:id])
  end

  def newsletter_email_params
    params.permit([:email])
  end

end
