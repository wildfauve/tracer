class Node
  
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  field :name, :type => String
  field :deleted, :type => Boolean
  
  scope :all_active, where(:deleted.ne => true)
  scope :all_archived, where(:deleted => true)
  scope :find_active, ->(type) { where(:type => type, :deleted.ne => true) }
  
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
      # Work with propertuies for a new node
      t.properties.keep_if {|p| p.name_prop == false}.each do |prop|
        node.propinstances << Propinstance.new(:ref => prop.id, :value => node_params[prop.name])
      end
    end
    node
  end
  
  def self.import(node, type_map, rt_map, build_only=false)
    current = self.where(:id => node["id"]).first
    fields = {}
    type = Type.find(type_map[node["type"]["id"]])
    fields[:type] = type.id
    fields[type.properties.where(:name_prop => true).first.name.to_sym] = node["name"]  
    node["propinstances"].each do |prop|
      fields[prop["name"]["name"]] = prop["value"]      
    end
    build_only ? fields : self.nodefactory(fields).create_the_node
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
  
  def self.delete_properties(props)
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
  
  def create_the_node(params={}) # :rel => Relinstance, :other_node => Node
    Rails.logger.info(">>>Node#create_the_node #{params.inspect} ")    
    if params[:rel]  # a relationship provided?
      params[:rel].relnode = params[:other_node].id
      self.relinstances << params[:rel]
    end
    save
    self
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
    this = self.relinstances.find(id)
    others = this.related_node.relinstances.where(:relnode => self.id)
    raise Exception if others.count > 1
    other = others.first
    this.destroy
    other.destroy
  end
  
  def remove_the_node
    #to_delete = []
    set_delete_on_relinstances(:to => true)    
    self.deleted = true
    #Rails.logger.info(">>>Node#remove_the_node self: #{self.id}  #{to_delete.inspect} ")    
    save!
  end
  
  
  
  def archive_perform
    set_delete_on_relinstances(:to => false)
    self.deleted = false
    save!
  end

  
# { "type"=>"51db3d9be4df1c5b0f000001", "name"=>"drive1", "desc"=>"dkfjdkfdkfdjff", "commit"=>"Confirm"}    
  def generate
    Jbuilder.encode do |j|
      j.name self.name
    end
    
  end
  
  private
  
  def set_delete_on_relinstances(archive_flag)
    self.relinstances.each do |relation|
      rel_node = relation.related_node
      rel_node.relinstances.each do |rel_inst|  # need to delete the other side of the relationship
        #to_delete << {:node => rel_node.related_node.name, :rel => rel_inst.id, :related => rel_inst.relnode} if rel_inst.relnode == self.id  
        rel_inst.deleted = archive_flag[:to] if rel_inst.relnode == self.id  
        rel_node.save! # save changes to related node relinstances
      end
      relation.deleted = archive_flag[:to] # delete the relations on self side
    end
  end
    
end