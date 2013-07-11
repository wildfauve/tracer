class Nodeset
# {"start"=>{"type"=>"51dcdea1e4df1c44c00000d3", "name"=>"Driver1", "desc"=>"A Driver"}, 
# "rel"=>{"type"=>"51dcdea2e4df1c44c00000ec"}, 
# "end"=>{"type"=>"51dcdea1e4df1c44c00000d6", "title"=>"Mechanism1", "desc"=>"A bloody good mechanism"}}  
  attr_accessor :start, :end
  
  def self.import(start_node, end_node, type_map, rt_map)
    return
  end
  
  def initialize
    @start = Node.nodefactory
    @end = Node.nodefactory
    self
  end
  
  def create(params)
    @rel = Relinstance.relfactory(params[:rel])
    @start = Node.nodefactory(params[:start], :start) 
    @end = Node.nodefactory(params[:end], :end)
    @rel.position = :start
    @start.create_the_node(:rel => @rel, :other_node => @end)
    @rel.position = :end
    @end.create_the_node(:rel => @rel, :other_node => @start)
    self
  end
    
end