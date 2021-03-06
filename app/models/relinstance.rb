class Relinstance
  
  include Mongoid::Document
  
  field :name, :type => String
  field :position, :type => String  
  field :reltype, :type => BSON::ObjectId
  field :relnode, :type => BSON::ObjectId
  field :archived, :type => Boolean

  embedded_in :node, :inverse_of => :relinstances
  embeds_many :relpropinstances


  def self.relfactory(params)
    Rails.logger.info(">>>Relinstance#relfactory #{params.inspect} ")
    rel = Relinstance.new
    rt = Reltype.find(params[:type])
    raise Exceptions::NoRelTypeError if rt.nil?
    rel.reltype = rt.id
    if !rt.properties.empty? # find the name prop and set it in the rel
      name_prop = rt.properties.where(:name_prop => true).first
      rel.name = params[name_prop.to_sym] if !name_prop.nil?
    end
    rt.properties.keep_if {|p| p.name_prop == false || p.name_prop.nil?}.each do |prop|
      #work with the properties
      rel.relpropinstances << Relpropinstance.new(:ref => prop.id, :value => params[prop.name])
    end
    rel
  end 
  
  def self.import(params)
    rel_params = {}
    params[:rel]["relpropinstances"].each {|relprop| rel_params[relprop["reltype_name"]] = relprop["value"]}
    rel_params[:type] = params[:rt_map][params[:rel]["reltype"]["reltypeid"]]
    rel_params
  end
  
  def update_rel(params)
    params[:rel].each do |k, v|
      inst = self.relpropinstances.where(:ref => k)
      if !inst.empty?
        inst.first.value = v
      else
        self.relpropinstances << Relpropinstance.new(:ref => k, :value => v)
      end
    end
    save!
  end
  
  def nodereltype
    Reltype.find(self.reltype)
  end
    
  def related_node
    Node.find(self.relnode)
  end
  
  def related_relinstance(args)
    # other_node: <node> reltype: <reltype>
    ri = self.related_node.relinstances.select {|rn| rn.nodereltype == args[:reltype] }
    ri.count > 1 ? raise : ri.first
  end
  
  def found_related_node?
    Node.where(id: self.relnode).count == 0 ? false : true
  end

end