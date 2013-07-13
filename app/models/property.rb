class Property

    
  include Mongoid::Document
    
  field :name, :type => String
  field :proptype, :type => String
  field :name_prop, :type => Boolean

  validates :name, exclusion: {in: [ "node", "type" ], message: "used a reserved word for a property name"}
  embedded_in :type, :inverse_of => :properties
  embedded_in :reltype, :inverse_of => :properties
  
end
