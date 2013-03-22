module ApplicationHelper
  def show_errors(model)  
  end
  
  def type_list
		@type_list || @type_list = Type.all.map{|t| [t.name, t.id]}
	end	
	
end
