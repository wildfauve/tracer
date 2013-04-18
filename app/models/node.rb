class Node
  
  include Mongoid::Document
  
  field :name, :type => String
  
  embeds_many :propinstances
  embeds_many :relinstances
  belongs_to :type
  
  accepts_nested_attributes_for :propinstances, :allow_destroy => true, 
                                :reject_if => proc {|attrs| attrs[:value].blank?}
  
  
# name = the name prop for the type
# type = ref to the type
# Prop instances, :propref = :implement_date, :propvalue = "0101010"
  def self.nodefactory(node_params)
    return Node.find(node_params[:node]) if node_params[:node]  # if this is an existing node
    node = Node.new
#    t = Type.where(:type_ref => node_params[:type]).first
    t = Type.find(node_params[:type])
    raise Exceptions::NoTypeError if t.nil?
    node.type = t
    node.name = node_params[t.properties.where(:name_prop => true).first.name.to_sym] # find the name prop and set it in the node
    t.properties.keep_if {|p| p.name_prop == false}.each do |prop|
      #work with the properties
      node.propinstances << Propinstance.new(:ref => prop.id, :value => node_params[prop.name])
    end
    node
  end
  
  def create_the_node(rel, noderel)
    rel.relnode = noderel.id 
    self.relinstances << rel
    save!
  end
  
  def update_the_node(params)
    self.attributes = params       
    save!
    return self
  end
  
  def delete_relation(id)
    here = self.relinstances.find(id)
    others = here.related_node.relinstances.where(:relnode => self.id)
    raise Exception if others.count > 1
    other = others.first
    here.destroy
    other.destroy
  end
    
end