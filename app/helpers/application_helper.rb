module ApplicationHelper
  def show_errors(model)  
  end
  
  def type_list
		@type_list || @type_list = Type.all.map{|t| [t.name, t.id]}
	end	
	
	def setup_reltype(reltype)
	  reltype.arcprop ||= Arcprop.new 
	  3.times {reltype.properties.build}
	  reltype
	end

	def setup_type(type)
	  3.times {type.properties.build}
	  type
	end

	
end
