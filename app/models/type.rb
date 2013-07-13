class Type
  @@per_page = 20
    
  include Mongoid::Document
  include Mongoid::Timestamps    
  
  field :type_ref, :type => String
  field :desc, :type => String
  
  embeds_many :properties
  has_many :node
  
  validates_uniqueness_of :type_ref
#  validate :has_assigned_reltypes, :on => :destroy
  before_destroy :has_assigned_reltypes, :has_assigned_nodes

  
  # TODO: Needs to not create the property if NIL
  accepts_nested_attributes_for :properties, :allow_destroy => true, 
                                :reject_if => proc {|attrs| attrs[:name].blank?}
                                
  
  def self.search(params)
    page = params[:page] || "1"
    doc_from = ((page.to_i - 1) * @@per_page)
    self.all.order_by([:year, :asc]).page(params[:page])
  end
  
  # {"type"=>{"type_ref"=>"test", 
  #         "properties_attributes"=>{"0"=>{"name"=>"name", "proptype"=>"string", "name_prop"=>"1", "_destroy"=>"0"}, 
  # =>      "1"=>{"name"=>"prop2", "proptype"=>"string", "name_prop"=>"0", "_destroy"=>"0"}, 
   # =>     "2"=>{"name"=>"", "proptype"=>"", "name_prop"=>"0", "_destroy"=>"0"}}}, "commit"=>"Create"}  
  def self.create_the_type(params)
    Rails.logger.info(">>>Type#create_the_type #{params[:properties_attributes]}")    
    type = self.new(params)  
    type.save
    return type
  end
  
#  {"id"=>"51db3d9be4df1c5b0f000001", "type_ref"=>"Arch Driver", "desc"=>nil, 
# "nodes"=>[{"id"=>"51db66c3e4df1c12cf000001", "name"=>"drive1"}], 
# "properties"=>[{"id"=>{"id"=>"51db3d9be4df1c5b0f000002"}, "name"=>{"propid"=>"51db3d9be4df1c5b0f000002", "name"=>"name"}, "proptype"=>"string", "name_prop"=>true}, {"id"=>{"id"=>"51db3d9be4df1c5b0f000003"}, "name"=>{"propid"=>"51db3d9be4df1c5b0f000003", "name"=>"desc"}, "proptype"=>"string", "name_prop"=>false}]}
  def self.import(type)
    current = self.where(:id => type["id"]).first
    params = {}
    params[:type_ref] = type["type_ref"]
    params[:desc] = type["desc"]
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

  def update_the_type(params)
    Rails.logger.info(">>>Type#update_the_type #{params}")        
    # when a property is removed, the properties need to be removed from any nodes as well
    
    # TODO: needs to send BSON ObjectId not string
    Node.delete_properties(params[:properties_attributes].select {|k,v| v[:_destroy] == "1"}.collect {|k,v| self.properties.find(v[:id])})
    self.attributes = params       
    save
    return self
  end
    
  def delete
    #raise Exceptions::TypeHasTypeRel if assigned_reltypes?
    self.destroy
    return self
  end  
  
  def has_assigned_reltypes?
    rt = Reltype.all
    return false if rt.count == 0
    Reltype.all.all? {|r| r.arcprop.start == self.id || r.arcprop.end == self.id }
  end
  
  def assigned_reltypes
    Reltype.all.keep_if {|r| r.arcprop.start == self.id || r.arcprop.end == self.id }
  end


  def nodes
    Node.find_active(self)
  end

  def name_prop
    self.properties.keep_if {|p| p.name_prop == true}.first
  end

  def find_associations(params)
      if params[:as] == "start_node"
          reltypes = Reltype.where('arcprop.start' => self.id)
          return {:node_ass => reltypes.map {|rt| rt.arcprop.end_node},
          :reltypes => reltypes}
      else # as end node
          reltypes = Reltype.where('arcprop.end' => self.id)          
          {:node_ass => reltypes.map {|rt| rt.arcprop.start_node}}
      end
  end
  
  def has_assigned_nodes?
    self.nodes.count > 0 ? true : false
  end
  
      
  private
    
  def has_assigned_reltypes
    Rails.logger.info(">>>Type#has_assigned_reltypes ")     
    errors.add(:type_ref, "Can't delete a Type if it has assigned relation types") if self.has_assigned_reltypes?
    errors.blank?
  end
  
  def has_assigned_nodes
    errors.add(:nodes, "Can't delete a Type if it has assigned nodes") if self.has_assigned_nodes?
    errors.blank?
  end
  
  
  
end