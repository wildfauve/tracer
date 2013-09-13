class EventsController < ApplicationController
  
  def index
    @events = Event.asc(:created_at)
  end
  
  def reset
    Event.all.delete
    respond_to do |format|
      format.html { redirect_to events_path }
    end
  end
  
end