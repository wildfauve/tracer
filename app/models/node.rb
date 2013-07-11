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
  def self.nodefactory(node_params=nil, position=nil)
    return Node.new if node_params.nil?    
    Rails.logger.info(">>>Node#Nodefactory #{node_params.inspect} ")
    return Node.find(node_params[:node]) if node_params[:node]  # if this is an existing node
    node = Node.new
    t = Type.find(node_params[:type])
    raise Exceptions::NoTypeError if t.nil?
    node.type = t
    raise
    node.name = node_params[t.properties.where(:name_prop => true).first.name.to_sym] # find the name prop and set it in the node
    t.properties.keep_if {|p| p.name_prop == false}.each do |prop|
      #work with the properties
      node.propinstances << Propinstance.new(:ref => prop.id, :value => node_params[prop.name])
    end
    node
  end
  
  def self.import(node, type_map, rt_map)
    current = self.where(:id => node["id"]).first
    params = {}
    params[:name] = node["name"]  # TODO :this bit is done by looking up type property for the name prop OH DEER
    params[:desc] = node["desc"]
    prop_attr = {}
    ct = 0
    type["properties"].each do |prop|
      prop["name_prop"] ? nameprop = "1" : nameprop = "0" 
      prop_attr[ct.to_s] = {:name => prop["name"]["name"], :proptype => prop["proptype"], :name_prop => nameprop, :_destroy => "0"}
      ct += 1
    end
    params[:properties_attributes] = prop_attr
    current ? t = current.update_the_type(params) : t = self.create_the_type(params)
    return t
    
    
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
  
  def create_the_node(params={}) # :rel => Relinstance, :other_node => Node
    Rails.logger.info(">>>Node#create_the_node #{params.inspect} ")    
    if params[:rel]  # a relationship provided?
      params[:rel].relnode = params[:other_node].id
      self.relinstances << params[:rel]
    end
    save
    self
  end
  
  def update_the_node(params)
    self.attributes = params       
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