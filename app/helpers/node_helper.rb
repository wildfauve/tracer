module NodeHelper
  def node_list(typearc=nil)
    if typearc
#      @node_list = []
      typearc[:node_ass].each do |end_type|
        @node_list = end_type.nodes.map{|n| ["#{n.type.type_ref}::#{n.name}", n.id]}
      end
    else
		  @node_list || @node_list = Node.all.map{|n| ["#{n.type.type_ref}::#{n.name}", n.id]}
	  end
	  return @node_list
	end	
end