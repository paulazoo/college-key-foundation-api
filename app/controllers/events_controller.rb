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
    @event.link = event_params[:public_link] if (event_params[:public_link] && event_params[:kind] == 'open')
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
  
  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.permit([:name, :description, :link, :kind, :start_time, :end_time, :image_url, :host, :public_link, \
      :public_name, :public_email, :public_link, invites: []])
  end
  
end
