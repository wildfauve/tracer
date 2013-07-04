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
    
  def self.create_the_type(params)
    Rails.logger.info(">>>Type#create_the_type #{params[:properties_attributes].count}")    
    type = self.new(params)  
    type.save
    return type
  end

  def update_the_type(params)
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
    Reltype.all.all? {|r| r.arcprop.start == self.id || r.arcprop.end == self.id }
  end
  
  def assigned_reltypes
    Reltype.all.keep_if {|r| r.arcprop.start == self.id || r.arcprop.end == self.id }
  end


  def nodes
    Node.find_active(self)
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