class Node
  
  include Mongoid::Document
  
  field :name, :type => String
  field :deleted, :type => Boolean
  
  embeds_many :propinstances
  embeds_many :relinstances
  belongs_to :type
  
  accepts_nested_attributes_for :propinstances, :allow_destroy => true, 
                                :reject_if => proc {|attrs| attrs[:value].blank?}
  
  
# name = the name prop for the type
# type = ref to the type
# Prop instances, :propref = :implement_date, :propvalue = "0101010"
  def self.nodefactory(node_params)
    Rails.logger.info(">>>Node#Nodefactory #{node_params.inspect} ")
    return Node.find(node_params[:node]) if node_params[:node]  # if this is an existing node
    node = Node.new
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
  
  def create_the_node(params={}) # :rel => Relinstance, :other_node => Node
    Rails.logger.info(">>>Node#create_the_node #{params.inspect} ")    
    if params[:rel]  # a relationship provided?
      params[:rel].relnode = params[:other_node].id
      self.relinstances << params[:rel]
    end
    save!
  end
  
  def update_the_node(params)
    self.attributes = params       
    save!
    return self
  end

  def add_relationship
    
  end
  
  def delete_relation(id)
    this = self.relinstances.find(id)
    others = this.related_node.relinstances.where(:relnode => self.id)
    raise Exception if others.count > 1
    other = others.first
    this.destroy
    other.destroy
  end
  
  def remove_the_node
    #to_delete = []
    self.relinstances.each do |relation|
      rel_node = relation.related_node
      rel_node.relinstances.each do |rel_inst|  # need to delete the other side of the relationship
        #to_delete << {:node => rel_node.related_node.name, :rel => rel_inst.id, :related => rel_inst.relnode} if rel_inst.relnode == self.id  
        rel_inst.deleted = true if rel_inst.relnode == self.id  
        rel_node.save! # save changes to related node relinstances
      end
      relation.deleted = true # delete the relations on self side
    end
    self.deleted = true
    #Rails.logger.info(">>>Node#remove_the_node self: #{self.id}  #{to_delete.inspect} ")    
    save!
  end
    
end