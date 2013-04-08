module TypeHelper
  def type_list
		@type_list || @type_list = Type.all.map{|t| [t.type_ref, t.id]}
	end	
  
end