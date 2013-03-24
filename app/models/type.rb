class Type
  @@per_page = 20
    
  include Mongoid::Document
    
  field :name, :type => String
  field :desc, :type => String
  
  embeds_many :properties
  
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
    #raise Exceptions::InvalidProfileConfidence if 
    Rails.logger.info(">>>Type#create_the_type #{params[:properties_attributes].count}")    
    type = self.new(params)
    #type.attributes = params       
    type.save!
    Rails.logger.info(">>>Type#create_the_type #{type.properties.count}")     
    return type
  end

  def update_the_type(params)
    #raise Exceptions::InvalidProfileConfidence if 
    self.attributes = params       
    save!
    return self
  end
    
  private
  
  
end