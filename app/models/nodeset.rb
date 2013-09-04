class Nodeset
# {"start"=>{"type"=>"51dcdea1e4df1c44c00000d3", "name"=>"Driver1", "desc"=>"A Driver"}, 
# ""rel"=>{"type"=>"51df95fbe4df1c89a6000048", "through"=>"even more magic"}, 
# "end"=>{"type"=>"51dcdea1e4df1c44c00000d6", "title"=>"Mechanism1", "desc"=>"A bloody good mechanism"}}  

# "start"=>{"type"=>"51df832de4df1c37b500020c", "node"=>"51df832de4df1c37b500022e"}  for existing node
  attr_accessor :start, :end
  
  def self.import(start_node, end_node, rel, type_map, rt_map, existing_node_id)
    fields = {}
    fields[:start] = Node.import(start_node, type_map, rt_map, true)
    fields[:start][:node] = existing_node_id if existing_node_id
    fields[:end] = Node.import(end_node, type_map, rt_map, true)
    fields[:rel] = Relinstance.import(:rel => rel, :rt_map => rt_map)
    self.new.create(fields)
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
    @start = @start.create_the_node(:rel => @rel, :other_node => @end)
    @rel.position = :end
    @end.create_the_node(:rel => @rel, :other_node => @start)
    self
  end
  
    
end