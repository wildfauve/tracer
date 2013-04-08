class Relinstance
  
  include Mongoid::Document
  
  field :name, :type => String
  field :reltype, :type => Moped::BSON::ObjectId
  field :relnode, :type => Moped::BSON::ObjectId

  embedded_in :node, :inverse_of => :relinstances
  embeds_many :relpropinstances


  def self.relfactory(params)
    rel = Relinstance.new
    rt = Reltype.where(:name => params[:type]).first
    raise Exceptions::NoRelTypeError if rt.nil?
    rel.reltype = rt.id
    rel.name = params[rt.properties.where(:name_prop => true).first.name.to_sym] if !rt.properties.empty? # find the name prop and set it in the rel
    rt.properties.keep_if {|p| p.name_prop == false}.each do |prop|
      #work with the properties
      rel.relpropinstances << Relpropinstance.new(:ref => prop.name, :value => params[prop.name])
    end
    rel
  end
  
  def nodereltype
    Reltype.find(self.reltype)
  end
  
  def related_node
    Node.find(self.relnode)
	end
	

end