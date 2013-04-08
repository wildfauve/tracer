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
    #Rails.logger.info(">>>CARDS MODEL SEARCH #{page}")
    doc_from = ((page.to_i - 1) * @@per_page)
    self.all.order_by([:year, :asc]).page(params[:page])
  end
    
  def self.create_the_type(params)
    Rails.logger.info(">>>Type#create_the_type #{params[:properties_attributes].count}")    
    type = self.new(params)  
    type.save!
    Rails.logger.info(">>>Type#create_the_type #{type.properties.count}")     
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

    
  private
  
  
  def has_assigned_reltypes
    Rails.logger.info(">>>Type#has_assigned_reltypes ")     
    errors.add(:type_ref, "Cant delete a type if it has assigned relation types") if self.has_assigned_reltypes?
    errors.blank?
  end
  
  
end