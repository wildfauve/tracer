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
  
  def create(args)
    Rails.logger.info(">>>Nodeset#create #{args.inspect} ")    
    @rel = Relinstance.relfactory(args[:rel])
    args[:start].class == Node ? @start = args[:start] : @start = Node.nodefactory(args[:start], :start) 
    args[:end].class == Node ? @end = args[:end] : @end = Node.nodefactory(args[:end], :end)
    Event.create_event(entry: ">>>NodeSet#create  Start: #{@start.name}  Rel: #{@rel.name} End: #{@end.name} ")    
    @rel.position = :start
    @start = @start.create_or_update_the_node(:rel => @rel, :other_node => @end)
    @rel.position = :end
    @end.create_or_update_the_node(:rel => @rel, :other_node => @start)

    # find the problem with relinstances other node....    
    # check_rel_i(@start)
    # check_rel_i(@end)
    
    self
  end
  
# "node"=>"5232cc51e4df1c8b30000ff8", 
# "other_node"=>"5232cc52e4df1c8b30001071", 
# "rel"=>{"type"=>"5232cc51e4df1c8b30000fee", "effect_value"=>"Test"}
  def update_node_rel_with_new_relinstances(args)
    @start = Node.find(args[:node])
    @end = Node.find(args[:other_node])
    @rel = Relinstance.relfactory(args[:rel])
    @rel.position = :start    
    @start = @start.create_or_update_the_node(:rel => @rel, :other_node => @end)
    @rel.position = :end
    @end.create_or_update_the_node(:rel => @rel, :other_node => @start)
    self
  end
  
# "rel"=>{"523abf8ce4df1c17a50000df"=>"-"}, "node_id"=>"523ab8e6e4df1c06ba000003", "id"=>"523ad000e4df1c9c57000003"  
# where we update a node's relationship using a slightly different rel structure
  def update_2(args)
    @start = Node.find(args[:node_id])
    @rel_start = @start.relinstances.find(args[:id])
    @end = @rel_start.related_node
    @rel_end = @rel_start.related_relinstance(reltype: @rel_start.nodereltype)
    @rel_start.update_rel(args)
    @rel_end.update_rel(args)
    #@rel.position = :start    
    #@start = @start.create_or_update_the_node(:rel => @rel, :other_node => @end)
    #@rel.position = :end
    #@end.create_or_update_the_node(:rel => @rel, :other_node => @start)
    @start
  end
  
  def check_rel_i(node)
    # need to make it blow up on Relinstances related_node method
    node.relinstances.each {|n| n.related_node}
    
  end
    
end