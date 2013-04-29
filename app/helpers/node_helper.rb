module NodeHelper
  def node_list
		@node_list || @node_list = Node.all.map{|n| ["#{n.type.type_ref}::#{n.name}", n.id]}
	end	
  
end