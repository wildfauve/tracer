module ReltypeHelper
  def reltype_list(subset=nil)
      if subset
          @reltype_list || @reltype_list = subset[:reltypes].all.map{|t| [t.name, t.id]}
      else 
	      @reltype_list || @reltype_list = Reltype.all.map{|t| [t.name, t.id]}
      end
	end
	
	def setup_reltype(reltype)
	  reltype.arcprop ||= Arcprop.new 
	  3.times {reltype.properties.build}
	  reltype
	end
	
end