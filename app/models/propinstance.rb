class Propinstance
  
  include Mongoid::Document
  
  field :ref, :type => Moped::BSON::ObjectId
  field :value, :type => String

  embedded_in :node, :inverse_of => :propinstances

  validates :value, exclusion: {in: [ "node", "type" ], message: "used a reserved word for a property name"}  

  def name
    Type.where('properties._id' => ref).first.properties.find(ref).name
  end

  def property
    Type.where('properties._id' => ref).first.properties.find(ref)
  end

end