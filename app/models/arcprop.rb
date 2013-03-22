class Arcprop
  include Mongoid::Document
    
  field :start, :type => String
  field :end, :type => String
  field :directed, :type => Boolean
  
  embedded_in :relationship
  
  def start_node
    return Type.find(self.start)
  end
  
  def end_node
    return Type.find(self.end)
  end
  
  
end