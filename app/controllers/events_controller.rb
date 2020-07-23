class EventsController < ApplicationController
  before_action :authenticate_account, only: %i[create index register join export_registered export_joined]

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

  # GET /events/public
  def public
    @public_events = Event.where(kind: 'open')
    render(json: @public_events, status: :ok)
  end

  # POST /events/:id/register
  def register
    @registration = @event.registrations.new(account: current_account, registered: true)

    if @registration.save
      render(json: @registration, status: :created)
    else
      render(json: @registration.errors, status: :unprocessable_entity)
    end
  end

  # POST /events/:id/public_register
  def public_register
    render(json: { message: 'Not a public event' }) if @event.kind != 'open'

    @registration = @event.registrations.new(ip_address: request.remote_ip, public_name: event_params[:public_name], public_email: event_params[:public_email], registered: true )

    if @registration.save
      render(json: @registration, status: :created)
    else
      render(json: @registration.errors, status: :unprocessable_entity)
    end
  end

  # POST /events/:id/join
  def join
    render(json: { message: 'This is not yet implemented' })
  end

  # POST /events/:id/public_join
  def public_join
    render(json: { message: 'This is not yet implemented' })
  end

  # GET /events/:id/export_registered
  def export_registered
    render(json: { message: 'You are not master' }, status: :unauthorized) unless is_master

    @registered = @event.registrations.where(registered: true)
    render(json: @registered)
  end
  
  # GET /events/:id/export_joined
  def export_joined
    render(json: { message: 'You are not master' }, status: :unauthorized) unless is_master
    
    @joined = @event.registrations.where(joined: true)
    render(json: @joined)
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.permit([:name, :description, :link, :kind, :start_time, :end_time, :image_url, :host, :public_name, :public_email, invites: []])
  end
  
end
