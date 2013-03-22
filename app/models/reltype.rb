class Reltype
    
  include Mongoid::Document
    
  field :name, :type => String
  
  embeds_many :properties
  embeds_one  :arcprop
  
  has_many :types  # from type, to type, or any(?)  has and belongs to many?

  # TODO: Needs to not create the property if NIL  
  accepts_nested_attributes_for :properties, :arcprop, :allow_destroy => true, :reject_if => :all_blank
  
  def self.search(params)
    page = params[:page] || "1"
    doc_from = ((page.to_i - 1) * @@per_page)
    self.all.order_by([:year, :asc]).page(params[:page])
  end
  
  
  def self.create_the_reltype(params)
    #raise Exceptions::InvalidProfileConfidence if 
    type = self.new params
    type.attributes = params
    type.save!
    return type
  end
      
  private
  
  
end