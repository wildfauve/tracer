class Property

    
  include Mongoid::Document
    
  field :name, :type => String
  field :proptype, :type => String
  field :name_prop, :type => Boolean

  embedded_in :type, :inverse_of => :properties
  
  
end
