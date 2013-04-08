class Arcprop
  include Mongoid::Document
    
  field :start, :type => Moped::BSON::ObjectId
  field :end, :type => Moped::BSON::ObjectId
  field :directed, :type => Boolean
  
  embedded_in :reltype
  
  def start_node
    return Type.find(self.start)
  end
  
  def end_node
    return Type.find(self.end)
  end
  
  def which?(type)
    type.id == self.start ? "Start" : "End"
  end
  
end