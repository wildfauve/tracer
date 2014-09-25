class Relpropinstance
  include Mongoid::Document
  
  field :ref, :type => BSON::ObjectId
  field :value, :type => String

  embedded_in :relation, :inverse_of => :propinstances

  validates :value, exclusion: {in: [ "node", "type" ], message: "used a reserved word for a property name"}
  
  def proptype
    Reltype.where('properties._id' => self.ref).first.properties.find(self.ref)
  end
  
end