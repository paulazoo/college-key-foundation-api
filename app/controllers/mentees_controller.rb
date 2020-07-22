class MenteesController < ApplicationController
  before_action :authenticate_account, only: %i[create index match batch]
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
    render(json: { message: 'You are not master' }, status: :unauthorized) if !is_master

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
    render(json: { message: 'You are not master' }, status: :unauthorized) if !is_master

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
    render(json: { message: 'You are not master' }, status: :unauthorized) if !is_master

    parsed_emails = mentee_params[:batch_emails].split(", ")

    finished_mentees = []

    parsed_emails.each do |email|
      @account = Account.find_by(email: email)

      if @account.blank?
        @mentee = Mentee.new()

        @mentee.account = Account.new(user: @mentee, email: email)

        if @mentee.save
          Analytics.identify(
            user_id: @mentee.account.id.to_s,
            traits: {
              role: 'Mentee',
              account_id: @mentee.account.id.to_s,
              email: email,
            },
          )

          finished_mentees.push(@mentee)
        else
          puts @mentee.errors
        end

      else
        puts 'Account already exists'
      end
    end

    render(json: { mentees: finished_mentees, status: :ok })
  end

  # mentee_name	mentor_name	mentee_email	mentor_email	mentee_phone	mentor_phone
  #  0           1           2             3             4             5
  # POST /mentees/import
  def import
    session = GoogleDrive::Session.from_service_account_key("client_secret.json")
    spreadsheet = session.spreadsheet_by_title(mentee_params[:file_name])
    worksheet = spreadsheet.worksheets.first
    rows = worksheet.rows
    headers, *data = rows

    data.each{ 
      |r|

      # first create the mentee record
      mentee_account = Account.find_by(email: r[2])

      if mentee_account.blank?
        @mentee = Mentee.new()

        @mentee.account = Account.new(user: @mentee, email: r[2], phone: r[4], name: r[0])

        if @mentee.save
        else
          puts @mentee.errors
        end

      else
        puts 'Account already exists'
        
        @mentee = mentee_account.user

        mentee_account.update(email: r[3], phone: r[5], name: r[0])
        
        if mentee_account.save
        else
          puts mentee_account.errors
        end
      end

      # now create the mentor record
      mentor_account = Account.find_by(email: r[3])

      if mentor_account.blank?
        @mentor = Mentor.new()

        @mentor.account = Account.new(user: @mentor, email: r[3], phone: r[5], name: r[1])

        if @mentor.save
        else
          puts @mentor.errors
        end

      else
        puts 'Account already exists'
        
        @mentor = mentor_account.user

        mentor_account.update(email: r[3], phone: r[5], name: r[1])
        
        if mentor_account.save
        else
          puts mentor_account.errors
        end
      end

      # now match mentee and mentor
      @mentee.mentor = @mentor

      if @mentee.save
      else
        puts @mentee.errors
      end
    }

    render(json: { message: 'Import successful!' })
  end

  # mentee_name	mentor_name	mentee_email	mentor_email	mentee_phone	mentor_phone
  #  0           1           2             3             4             5
  # POST /mentees/import_info
  def import_info
    session = GoogleDrive::Session.from_service_account_key("client_secret.json")
    spreadsheet = session.spreadsheet_by_title(mentee_params[:file_name])
    worksheet = spreadsheet.worksheets.first
    rows = worksheet.rows
    headers, *data = rows

    data.each{ 
      |r|
    }

    render(json: { message: 'Import successful!' })
  end

  private

  def set_mentee
    @mentee = Mentee.find(params[:id])
  end

  def mentee_params
    params.permit([:email, :mentee_id, :mentor_id, :batch_emails, :file_name])
  end
end
