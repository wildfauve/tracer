class Compare
  
  attr_accessor :matrix, :titles
  
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  field :name, :type => String
  field :x, type: Moped::BSON::ObjectId
  field :y, type: Moped::BSON::ObjectId
  field :rel , type: Moped::BSON::ObjectId
  
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
  
  def show_it
    matx = []
    y_axis = []
    x_types = nodes_from_type(self.x)
    y_types = nodes_from_type(self.y)
    @titles = x_types
    @matrix = Matrix[[1,2,3], [4,5,6], [7,8,9]]
    self
  end
  
  def delete_it
    self.destroy
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
  
  def axis_title(params)
    params[:x] ? self.related_type(self.x).type_ref : self.related_type(self.y).type_ref
  end
  
  def relation_title
    self.reltype.name
  end
  
end