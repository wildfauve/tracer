module ApplicationHelper
  def title(page_title, sup_title = "")
      content_for(:title, page_title.to_s + ":" + sup_title.to_s )
  end

  def show_errors(model)  
  end
  	
  def setup_type(type)
      3.times {type.properties.build}
      type
  end

end
