module CompareHelper
  def compare_rel_attr_list(properties)
      properties.map{|p| [p.name, p.id]}
  end
end