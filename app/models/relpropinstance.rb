class Relpropinstance
  include Mongoid::Document
  
  field :ref, :type => Moped::BSON::ObjectId
  field :value, :type => String

  embedded_in :relation, :inverse_of => :propinstances
  
  def proptype
    Reltype.where('properties.id' == self.ref).first.properties.find(self.ref)
  end
  
end