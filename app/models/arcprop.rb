class Arcprop
  include Mongoid::Document
    
  field :start, :type => BSON::ObjectId
  field :end, :type => BSON::ObjectId
  field :directed, :type => Boolean
  
  embedded_in :reltype
  
  # {"start"=>"542289494d6174d626100000", "end"=>"542288044d6174d6260c0000", "directed"=>"0"}
  
  def self.create_me(arc: nil)
    self.new.add_arc(arc: arc)
  end
  
  def add_attrs(arc: nil)
    self.start = Type.find(arc[:start]).id
    self.end = Type.find(arc[:end]).id
    self.directed = arc[:directed]
    self
  end
  
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