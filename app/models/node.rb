class Node
  
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  field :name, :type => String
  field :archived, :type => Boolean
  
  scope :all_active, ->(filter=nil) do
    where(:archived.ne => true)
  end
  scope :all_archived, -> {where(:archived => true)}
  scope :find_active, ->(type) do 
    where(:type => type, :archived.ne => true)
  end
  
  validates :name, exclusion: {in: [ "node", "type" ], message: "used a reserved word for a Node name"}  
  
  validates_uniqueness_of :name
  
  embeds_many :propinstances
  embeds_many :relinstances
  belongs_to :type
  
  accepts_nested_attributes_for :propinstances, :allow_destroy => true, 
                                :reject_if => proc {|attrs| attrs[:value].blank?}
  
  
# {"type"=>"51dce71de4df1c1e6f000133", "title"=>"r2", "desc"=>"rr2", "likelihood"=>"1", "impact"=>"1", "commit"=>"Confirm"}
  def self.nodefactory(node_params=nil, position=nil, node_id=nil)
    return Node.new if node_params.nil?    
    Rails.logger.info(">>>Node#Nodefactory #{node_params.inspect} ")
    return Node.find(node_params[:node]) if node_params[:node]  # if this is an existing node
    node_id ? node = Node.find(node_id) : node = Node.new
    t = Type.find(node_params[:type])
    raise Exceptions::NoTypeError if t.nil?
    node.type = t
    node.name = node_params[t.properties.where(:name_prop => true).first.name.to_sym] # find the name prop and set it in the node
    # when Node id is provided this is an update function
    if node_id
      node.propinstances.each do |pi|
        pi.value = node_params[pi.name]
      end
  		pi = node.propinstances.collect {|pi| pi.name}
  		t = node.type.properties.collect {|p| p if p.name_prop == false}
  		t.delete_if {|i| i.nil? || pi.find_index(i.name)}.each do |p|
  		  node.propinstances << Propinstance.new(:ref => p.id, :value => node_params[p.name])
		  end
    else
      # Work with properties for a new node
      t.properties.keep_if {|p| p.name_prop == false}.each do |prop|
        node.propinstances << Propinstance.new(:ref => prop.id, :value => node_params[prop.name])
      end
    end
    node
  end
  
  
  # Build_only=true is for a node with relationships, false is for a node without 
  
  def self.import(node, type_map, rt_map, build_only=false)
    current = self.where(id: node["id"]).first  # has the node already exist BEFORE the import
    current = self.where(name: node["name"]).first if !current  # now what say we have already created it DURING the import?
    fields = {}
    type = Type.find(type_map[node["type"]["id"]])
    fields[:type] = type.id
    fields[type.properties.where(:name_prop => true).first.name.to_sym] = node["name"]  
    node["propinstances"].each do |prop|
      fields[prop["name"]["name"]] = prop["value"]      
    end
    Event.create_event(entry: "Node#Import: #{node["name"]} is a Single Node") if !build_only
    if build_only
      if current
        return self.nodefactory(fields, nil, current.id).update_the_node
      else
        return fields
      end
    end
    Event.create_event(entry: "Node#Import Current: #{current.inspect}")
    self.nodefactory(fields).create_or_update_the_node
  end
  
  def self.related_reltypes(reltype_id)
    return self.where('relinstances.reltype' => reltype_id) 
  end
  
  def self.node_pairs(node_filter=nil)
    pairs = []
    node_filter ? nodes = node_filter : nodes = Node.all
    nodes.each do |n| 
      n.relinstances.each do |rel|
        pairs << {:start => n, :end => rel.related_node} if !pairs.find_index({:end => n, :start => rel.related_node})
      end
    end
    pairs
  end
  
  def self.delete_properties(props: nil)
    props.each do |prop|
      self.where('propinstances.ref' => prop.id).each do |node|
        node.propinstances.select {|pi| pi.ref == prop.id}.each {|pii| pii.destroy}
        node.save
      end
    end
  end

  def self.delete_rel_prop(rel_type, props)
    nodes = Node.where('relinstances.reltype' => rel_type.id) 
    nodes.each do |node|
      node.relinstances.each do |ri|
        if ri.reltype == rel_type.id
          props.each do |prop|
            ri.relpropinstances.each do |rpi|
              rpi.destroy if rpi.ref == prop.id
            end
          end
        end
      end
      node.save
    end
  end
  
  def create_or_update_the_node(params={}) # :rel => Relinstance, :other_node => Node
    Event.create_event(entry: "Node#create #{self.id} #{self.name} Created") 
    if params[:rel]  # a relationship provided?
      params[:rel].relnode = params[:other_node].id
      self.relinstances << params[:rel]
    end
    save
    self
  end
  
  def check_rel_i(node)
    # need to make it blow up on Relinstances related_node method
    node.relinstances.each {|n| Event.create_event(entry: ">>>Node#check_rel_i  Node: #{node.name} #{n.inspect}   Found? #{n.found_related_node?}" )}
  end
  
  

# CREATE Params  {"type"=>"51e069c5e4df1c7435000011", "name"=>"D1000", "desc"=>"A description"}
# Update Params  {"type"=>"51e069c5e4df1c7435000011", "name"=>"D1000", "desc"=>"A description A DDDD"}  
  def update_the_node
    save
    self
  end

  def add_relationship
    
  end
  
  def delete_relation(id)
    this_rel = self.relinstances.find(id)
    others_rel = this_rel.related_node.relinstances.where(:relnode => self.id)
    raise Exception if others_rel.count > 1
    other_rel = others_rel.first
    this_rel.destroy
    other_rel.destroy
  end
  
  def remove_the_node
    #to_delete = []
    set_delete_on_relinstances(:to => true)    
    self.archived = true
    #Rails.logger.info(">>>Node#remove_the_node self: #{self.id}  #{to_delete.inspect} ")    
    save!
  end
  
  
  
  def archive_perform
    set_delete_on_relinstances(:to => false)
    self.archived = false
    save!
  end

  
# { "type"=>"51db3d9be4df1c5b0f000001", "name"=>"drive1", "desc"=>"dkfjdkfdkfdjff", "commit"=>"Confirm"}    
  def generate
    Jbuilder.encode do |j|
      j.name self.name
    end
  end
  
  def has_related_reltypes?(reltype_id)
    self.relinstances.any? {|ri| ri.reltype == reltype_id}
  end
  
#  {other_node: <node>, rel_type_id: <reltype>, rel_attr: <relpropinstance, return: <:rel_attr | :rel_id>}
  def rel_attribute(args)
    inst = self.relinstances.select {|ri| ri.reltype == args[:rel_type_id] && ri.relnode == args[:other_node].id}
    raise if inst.count > 1
    return "" if inst.count == 0 
    if args[:return] == :rel_id
      return inst.first.id
    else
      rel_attr = inst.first.relpropinstances.select {|rpi| rpi.ref == args[:rel_attr]}.first
      return rel_attr.nil? ? "X" : rel_attr.value
    end
  end
  
  def new_properties
    pi = self.propinstances.collect {|pi| pi.name}
    all_props = self.type.properties.select {|p| p if p.name_prop == false}
    all_props.delete_if {|p| self.propinstances.where(ref: p.id).first }
  end
  
  
  private
  
  def set_delete_on_relinstances(archive_flag)
    self.relinstances.each do |relation|
      rel_node = relation.related_node
      rel_node.relinstances.each do |rel_inst|  # need to delete the other side of the relationship
        #to_delete << {:node => rel_node.related_node.name, :rel => rel_inst.id, :related => rel_inst.relnode} if rel_inst.relnode == self.id  
        rel_inst.archived = archive_flag[:to] if rel_inst.relnode == self.id  
        rel_node.save! # save changes to related node relinstances
      end
      relation.archived = archive_flag[:to] # delete the relations on self side
    end
  end
    
end