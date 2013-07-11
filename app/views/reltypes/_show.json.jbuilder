json.reltypes reltypes do |json,rtype|
  json.(rtype, :id)
  json.(rtype, :name)
  json.(rtype, :desc)
  json.properties rtype.properties do |json,prop|
    json.id(prop, :id)
    json.name do
      json.propid prop.id
      json.name prop.name
    end
    json.(prop, :proptype)
    json.(prop, :name_prop)    
  end
  json.arcprop do
    json.start_node_type do
      json.id rtype.arcprop.start_node.id
      json.type_ref rtype.arcprop.start_node.type_ref      
    end
    json.end_node_type do
      json.id rtype.arcprop.end_node.id
      json.type_ref rtype.arcprop.end_node.type_ref      
    end
  end
  
end