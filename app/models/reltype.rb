class Reltype
    
  include Mongoid::Document
    
  field :name, :type => String
  field :desc, :type => String

  
  embeds_many :properties
  embeds_one  :arcprop
  
  has_many :types  # from type, to type, or any(?)  has and belongs to many?

  # TODO: Needs to not create the property if NIL  
  accepts_nested_attributes_for :properties, :allow_destroy => true, :reject_if => proc {|attrs| attrs[:name].blank?}
  accepts_nested_attributes_for :arcprop, :allow_destroy => true

  before_destroy :has_assigned_nodes
  
  def self.search(params)
    page = params[:page] || "1"
    doc_from = ((page.to_i - 1) * @@per_page)
    self.all.order_by([:year, :asc]).page(params[:page])
  end
  
  
  def self.create_the_reltype(params)
    type = self.new params
#    type.attributes = params
    type.save!
    type
  end

  def update_the_reltype(params)
    self.attributes = params       
    save!
    self
  end

  def get_type_from_position(position)
      if position == 'start_node'
          self.arcprop.start_node
      else
          self.arcprop.end_node
      end
  end
  
  def find_associations
      {:node_ass => [self.arcprop.end_node]}
  end

  def remove_the_reltype
    self.destroy
    return self    
  end
  
  def has_assigned_nodes?
    Node.related_reltypes(self.id).count > 1 ? true : false
  end
  
  def assigned_nodes
    Node.related_reltypes(self.id)
  end
      
  private
  
  def has_assigned_nodes
    Rails.logger.info(">>>Reltype#has_assigned_nodes ")     
    errors.add(:type_ref, "Can't delete a Reltype if it has assigned nodes") if self.has_assigned_nodes? 
    errors.blank?
  end
  
end