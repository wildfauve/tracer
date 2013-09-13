class Event
    
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :entry, type: String
  
  def self.create_event(event)
    event = self.new(event)
    event.save
    event
  end

end