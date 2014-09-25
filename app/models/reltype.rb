class Reltype
  
  include Wisper::Publisher
  include Mongoid::Document
  include Mongoid::Timestamps
    
  field :name, :type => String
  field :desc, :type => String

  
  embeds_many :properties
  embeds_one  :arcprop
  
  has_many :types  # from type, to type, or any(?)  has and belongs to many?

  # TODO: Needs to not create the property if NIL  
  accepts_nested_attributes_for :properties, allow_destroy: true, :reject_if => proc {|attrs| attrs[:name].blank?}
  accepts_nested_attributes_for :arcprop

  before_destroy :has_assigned_nodes
  
  def self.search(params)
    page = params[:page] || "1"
    doc_from = ((page.to_i - 1) * @@per_page)
    self.all.order_by([:year, :asc]).page(params[:page])
  end
  
# "reltype"=>{"name"=>"has_a", "desc"=>"", 
# "properties_attributes"=>{"0"=>{"name"=>"name", "proptype"=>"string", "name_prop"=>"1", "_destroy"=>"0"}, 
# "1"=>{"name"=>"", "proptype"=>"", "name_prop"=>"0", "_destroy"=>"0"}, 
# "2"=>{"name"=>"", "proptype"=>"", "name_prop"=>"0", "_destroy"=>"0"}}, 
# "arcprop_attributes"=>{"start"=>"51dccd8de4df1c6e31000096", "end"=>"51dccd8de4df1c6e31000099", "directed"=>"0"}}

  def self.import(rt, type_map)
    current = self.where(:id => rt["id"]).first
    params = {}
    params[:name] = rt["name"]
    params[:desc] = rt["desc"]
    prop_attr = {}
    ct = 0
    rt["properties"].each do |prop|
      prop["name_prop"] ? nameprop = "1" : nameprop = "0" 
      prop_attr[ct.to_s] = {:name => prop["name"]["name"], :proptype => prop["proptype"], :name_prop => nameprop, :_destroy => "0"}
      ct += 1
    end
    params[:properties_attributes] = prop_attr
    start = type_map[rt["arcprop"]["start_node_type"]]
    params[:arcprop_attributes] = {:start => type_map[rt["arcprop"]["start_node_type"]["id"]], :end => type_map[rt["arcprop"]["end_node_type"]["id"]]}
    current ? res = current.update_the_reltype(params) : res = self.create_the_reltype(params)
    return res
  end

  def self.factory(params)
    Reltype.find(params[:type])
  end

  def create_me(reltype: nil)
    update_me(reltype: reltype)
  end

  def update_me(reltype: nil)
    reltype.permit!
    self.attributes = reltype
    determine_node_changes(props: reltype[:properties_attributes])
    #self.name = reltype[:name]
    #self.desc = reltype[:desc]
    #self.update_properties(props: reltype[:properties_attributes])
    #self.update_arc(arc: reltype[:arcprop_attributes])
    self.save
    publish(:successful_create, self)
  end

  def determine_node_changes(props: nil)
    Node.delete_rel_prop(self, props: props.select {|k,v| v[:_destroy] == "1"}.collect {|k,v| self.properties.find(v[:id])})
  end


=begin
  def update_properties(props: nil)

    props.delete_if {|ct, p| p[:name] == ""}
    props.each do |position, prop|
      p = self.properties.where(name: prop[:name]).first
      if p
        if prop[:_destroy] == "1"
          p.delete
        else
          p.add_attrs(prop: prop)
        end
      else
        p = Property.new.add_attrs(prop: prop)
        self.properties << p
      end
    end
  end

  def update_arc(arc: nil)
    if self.arcprop
      self.arcprop.add_attrs(arc: arc)
    else
      self.arcprop = Arcprop.create_me(arc: arc)
    end
  end
=end

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