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

  def error_content(ar_obj=nil)
    return if ar_obj.nil?
    if ar_obj.errors.any?
      content_tag(:div, :class => 'error_explanation') do
        concat(content_tag(:h2, "#{pluralize(ar_obj.errors.count, "error")} prohibited the Model from being saved:"))
        concat(content_tag(:ul) do
          ar_obj.errors.full_messages.each do |msg| 
            concat(content_tag(:li,msg))
          end
        end)
      end
    end
  end


end
