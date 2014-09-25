class Property

    
  include Mongoid::Document
    
  field :name, :type => String
  field :proptype, :type => Symbol
  field :name_prop, :type => Boolean

  validates :name, exclusion: {in: [ "node", "type" ], message: "used a reserved word for a property name"}
  embedded_in :type, :inverse_of => :properties
  embedded_in :reltype, :inverse_of => :properties

  def self.types
    [["String", :string], ["Long Text", :long_text], ["Integer", :integer] ]
  end
  
  def add_attrs(prop: nil)
    self.name = prop[:name]
    self.proptype = prop[:proptype]
    self.name_prop = prop[:name_prop]
    self
  end
  
end
