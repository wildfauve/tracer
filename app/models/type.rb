class Type
  @@per_page = 20
    
  include Mongoid::Document
    
  field :type_ref, :type => String
  field :desc, :type => String
  
  embeds_many :properties
  has_many :node
  
#  validate :has_assigned_reltypes, :on => :destroy
  before_destroy :has_assigned_reltypes

  
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
    type.save!
    return type
  end

  def update_the_type(params)
    self.attributes = params       
    save!
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
    Node.where(:type => self)
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
      
  private
  
  
  def has_assigned_reltypes
    Rails.logger.info(">>>Type#has_assigned_reltypes ")     
    errors.add(:type_ref, "Cant delete a type if it has assigned relation types") if self.has_assigned_reltypes?
    errors.blank?
  end
  
  
end