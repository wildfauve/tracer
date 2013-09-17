class Compare
  
  attr_accessor :matrix, :titles
  
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  field :name, :type => String
  field :x, type: Moped::BSON::ObjectId
  field :y, type: Moped::BSON::ObjectId
  field :rel, type: Moped::BSON::ObjectId
  field :rel_attr, type: Moped::BSON::ObjectId
  
  # Input into create is the format of the standard node forms, hence:
  # "start"=>{"type"=>"521ac0e4e4df1cfb1a00003c"}, 
  # "rel"=>{"type"=>"521ac0e4e4df1cfb1a000062"}, "end"=>{"type"=>"521ac0e4e4df1cfb1a000055"}
  
  def self.create_it(params)
    ts = Typeset.new.load(params)
    matx = Compare.new
    matx.x = ts.start_type.id
    matx.y = ts.end_type.id
    matx.rel = ts.rel_type.id
    matx.name = ts.standardise_name
    matx.save!
    matx
  end
  
  def self.show_it(params)
    matx = Compare.find(params[:id]).show_it
  end
  
  def self.delete_it(params)
    matx = Compare.find(params[:id]).delete_it
    matx
  end
  
  # {"id":"52247905e4df1cc1b5000001","name":"Quality-Attribute->has_quality_category_of->NFR-Cat",
  # "start":{"type":{"type_ref":"Quality Attribute"}},
  # "end":{"type":{"type_ref":"NFR Cat"}},
  # "rel":{"type":{"type_ref":"has_quality_category_of"}}}
  def self.import(compare)
    current = self.where(:id => compare["id"]).first
    x = Type.where(type_ref: compare["start"]["type"]["type_ref"]).first
    y = Type.where(type_ref: compare["end"]["type"]["type_ref"]).first
    rel = Reltype.where(name: compare["rel"]["type"]["type_ref"]).first
    params = {start: {type: x.id}, end: {type: y.id}, rel: {type: rel.id} }
    current ? c = current.update_the_type(params) : c = self.create_it(params)
  end
  
  def self.get_rel_attrs(params)
    self.find(params[:id])
  end

  def self.set_rel_attrs(params)
    c = self.find(params[:id])
    c.rel_attr = params[:rel_attr]
    c.save!
    c
  end

  
  def show_it
    matx = []
    y_axis = []
    @x_types = nodes_from_type(self.x)
    @y_types = nodes_from_type(self.y)
    #@titles = @x_types
    @matrix = Matrix.build(@y_types.size + 1,@x_types.size + 1) do |row,col|
      if row == 0 && col == 0
        "Head"
      elsif col == 0
        @y_types[row - 1].name if col == 0
      elsif row == 0
        @x_types[col - 1].name
      else
        rel_inst = @y_types[row - 1].rel_attribute(other_node: @x_types[col - 1], rel_type_id: self.rel, rel_attr: self.rel_attr)
        rel_inst
      end
    end
    self
  end
  
  def delete_it
    self.destroy
    self
  end
  
  def nodes_from_type(type)
    nodes = self.related_type(type).nodes
    nodes.select {|n| n.has_related_reltypes?(self.reltype.id)}
  end
  
  def reltype
    Reltype.find(self.rel)
  end
  
  def related_type(axis)
    Type.find(axis)
  end
  
  def axis_title(args)
    args[:axis] == :x ? self.related_type(self.x).type_ref : self.related_type(self.y).type_ref
  end
  
  def relation_title
    self.reltype.name
  end
  
  def x_axis_size
    @x_types.size + 1
  end

  def y_axis_size
    @y_types.size
  end

  def rel_prop
    rt_prop = Reltype.where('properties._id' => self.rel_attr).first
    rt_prop.properties.select{|p| p.id == self.rel_attr}.first
  end
  
end