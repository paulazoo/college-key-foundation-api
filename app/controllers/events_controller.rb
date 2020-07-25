class EventsController < ApplicationController
  before_action :authenticate_account, only: %i[create index register unregister join export_registered export_joined]
  before_action :set_event, only: [:register, :unregister, :join, :public_register, :public_join, :export_registered, :export_joined]

  # GET /events
  def index
    if is_master
      @events = Event.all
      json_response(@events)
    else
      render(json: { message: 'You are not master' }, status: :unauthorized)
    end
  end

  # POST /events
  def create
    @event = Event.new(name: event_params[:name], kind: event_params[:kind])
    @event.description = event_params[:description] if event_params[:description]
    @event.link = event_params[:link] if event_params[:link]
    @event.image_url = event_params[:image_url] if event_params[:image_url]
    @event.host = event_params[:host] if event_params[:host]

    @event.start_time = DateTime.iso8601(event_params[:start_time]) if event_params[:start_time]
    @event.end_time = DateTime.iso8601(event_params[:end_time]) if event_params[:end_time]

    if @event.save

      if @event.kind === 'invite-only' && event_params[:invites]
        event_params[:invitees].each do |email|
          a = Account.find_or_create_by(email: email)
          @event.invitations.create!(account: a)
        end
      end

      render(json: @event, status: :created)
    else
      render(json: @event.errors, status: :unprocessable_entity)
    end
  end

  # name, description, link, kind, start_time, end_time, image_url, host, invites: []
  #  0    1            2     3     4           5          6          7     8
  # POST /events/import_batch
  def import_batch
    session = GoogleDrive::Session.from_service_account_key("client_secret.json")
    spreadsheet = session.spreadsheet_by_title(event_params[:file_name])
    worksheet = spreadsheet.worksheets.first
    rows = worksheet.rows
    headers, *data = rows

    data.each{ 
      |r|

      @event = Event.new(name: r[0], kind: r[3])
      @event.description = r[1] if r[1]
      @event.link = r[2] if r[2]
      @event.image_url = r[6] if r[6]
      @event.host = r[7] if r[7]
  
      @event.start_time = DateTime.iso8601(r[4]) if r[4]
      @event.end_time = DateTime.iso8601(r[5]) if r[5]
  
      if @event.save
  
        if @event.kind === 'invite-only' && r[8].split(", ")
          r[8].split(", ").each do |email|
            a = Account.find_or_create_by(email: email)
            @event.invitations.create!(account: a)
          end
        end
  
      else
        puts @event.errors
      end
    }

    render(json: { message: "Import successful!" })
  end

  # GET /events/public
  def public
    @public_events = Event.where(kind: 'open')
    render(json: @public_events, status: :ok)
  end

  # POST /events/:id/register
  def register
    @registration = @event.registrations.find_or_create_by(account: current_account)

    @registration.update(registered: true)

    if @registration.save
      @event.current_account = current_account

      render(json: @event.to_json(methods: [:account_registration]), status: :created)
    else
      render(json: @registration.errors, status: :unprocessable_entity)
    end
  end

  # POST /events/:id/unregister
  def unregister
    @registration = @event.registrations.find_or_create_by(account: current_account)

    @registration.update(registered: false)

    if @registration.save
      @event.current_account = current_account

      render(json: @event.to_json(methods: [:account_registration]), status: :created)
    else
      render(json: @registration.errors, status: :unprocessable_entity)
    end
  end

  # POST /events/:id/public_register
  def public_register
    render(json: { message: 'Not a public event' }) if @event.kind != 'open'

    @registration = @event.registrations.find_or_create_by(ip_address: request.remote_ip.to_s)

    @registration.update(public_name: event_params[:public_name], public_email: event_params[:public_email], registered: true)

    if @registration.save
      render(json: @registration, status: :created)
    else
      render(json: @registration.errors, status: :unprocessable_entity)
    end
  end

  # POST /events/:id/join
  def join
    @registration = @event.registrations.find_or_create_by(account: current_account)

    @registration.update(joined: true)

    if @registration.save
      @event.current_account = current_account

      render(json: @event.to_json(methods: [:account_registration]), status: :created)
    else
      render(json: @registration.errors, status: :unprocessable_entity)
    end
  end

  # POST /events/:id/public_join
  def public_join
    @registration = @event.registrations.find_or_create_by(ip_address: request.remote_ip.to_s)

    @registration.update(joined: true)

    if @registration.save
      render(json: @registration, status: :created)
    else
      render(json: @registration.errors, status: :unprocessable_entity)
    end
  end

  # GET /events/:id/export_registered
  def export_registered
    render(json: { message: 'You are not master' }, status: :unauthorized) unless is_master

    @registered = @event.registrations.where(registered: true)

    session = GoogleDrive::Session.from_service_account_key("client_secret.json")
    spreadsheet = session.spreadsheet_by_title(event_params[:file_name])
    worksheet = spreadsheet.worksheets.first

    worksheet.insert_rows(worksheet.num_rows + 1,
      [
        ["Event Id:", @event.id.to_s],
        ["Nam:", @event.name],
        ["Hosted by:", @event.host],
        ["Kind:", @event.kind],
        ["Start Time:", @event.start_time.to_s],
        ["End Time:", @event.end_time.to_s],
        [""],
        ["Logged In?", "Account Type", "Account Name", "Account Email", "Account Phone", "Ip Address", "Public Name", "Public Email"]
      ]
    )

    @registered.each{ 
      |r|
      if !r.account.blank?
        worksheet.insert_rows(worksheet.num_rows + 1,
          [
            ["Yes!", r.account.user_type, r.account.name, r.account.email, r.account.phone, "N/A", "N/A", "N/A"],
          ]
        )
      else
        worksheet.insert_rows(worksheet.num_rows + 1,
          [
            ["No", "N/A", "N/A", "N/A", "N/A", r.ip_address, r.public_name, r.public_email],
          ]
        )
      end
    }

    worksheet.save

    render(json: { message: 'Export successful!'})
  end

  # GET /events/:id/export_joined
  def export_joined
    render(json: { message: 'You are not master' }, status: :unauthorized) unless is_master

    @joined = @event.registrations.where(joined: true)
    render(json: { message: 'Export successful!'})
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.permit([:name, :description, :link, :kind, :start_time, :end_time, :image_url, :host, :public_name, :public_email, :file_name, invites: []])
  end
  
end
