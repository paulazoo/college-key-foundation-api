class EventsController < ApplicationController
  before_action :authenticate_account, only: %i[create index]

  # GET /events
  def index
    @events = Event.all
    json_response(@events)
  end

  # POST /events
  def create
    @event = Event.new(name: event_params[:name], kind: event_params[:kind])
    @event.description = event_params[:description] if event_params[:description]
    @event.description = event_params[:link] if event_params[:link]
    @event.description = event_params[:start_time] if event_params[:start_time]
    @event.description = event_params[:end_time] if event_params[:end_time]
    @event.description = event_params[:image_url] if event_params[:image_url]

    if @event.save
      
      if @event.kind === 'invite-only' && event_params[:invites]
        event_params[:invitees].each do |email|
          a = Account.find_or_create_by(email: email)
          @event.invitations.create!(account: a)
        end
      end
      
      render(json: @event, status: :created)
    else
      render(json: @event.errors, status: :created)
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def event_params
    params.permit([:name, :description, :link, :kind, :start_time, :end_time, :image_url, invites: []])
  end
  
end