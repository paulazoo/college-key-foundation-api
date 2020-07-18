class EventsController < ApplicationController
  before_action :authenticate_account, only: %i[create index]

    # GET events
    def index
      @events = Event.all
      json_response(@events)
    end
  
    # POST /events
    def create
    end
  
end
