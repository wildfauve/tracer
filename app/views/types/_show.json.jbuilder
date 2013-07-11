json.types types do |json,type|
  json.(type, :id)
  json.(type, :type_ref)
  json.(type, :desc)
  json.nodes type.node do |json, node|
    json.(node, :id)
    json.(node, :name)
  end
  json.properties type.properties do |json,prop|
    json.id(prop, :id)
    json.name do
      json.propid prop.id
      json.name prop.name
    end
    json.(prop, :proptype)
    json.(prop, :name_prop)    
  end
end