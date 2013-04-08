module ReltypeHelper
  def reltype_list
	  @reltype_list || @reltype_list = Reltype.all.map{|t| [t.name, t.id]}
	end
	
	def setup_reltype(reltype)
	  reltype.arcprop ||= Arcprop.new 
	  3.times {reltype.properties.build}
	  reltype
	end
	
end