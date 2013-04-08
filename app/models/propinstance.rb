class Propinstance
  
  include Mongoid::Document
  
  field :ref, :type => Moped::BSON::ObjectId
  field :value, :type => String

  embedded_in :node, :inverse_of => :propinstances

  def name
    Type.where('properties._id' => ref).first.properties.find(ref).name
  end


end