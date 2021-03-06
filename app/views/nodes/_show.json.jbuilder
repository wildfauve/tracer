json.nodes nodes do |node|
  json.(node, :id)
  json.(node, :name)
  json.(node, :archived)
  json.type do 
    json.type_ref node.type.type_ref
    json.id node.type.id
  end
  json.relinstances node.relinstances do |rel|
    json.(rel, :id)
    json.(rel, :name)
    json.reltype do
      json.id rel.id
      json.reltypeid rel.nodereltype.id
      json.name rel.nodereltype.name
      json.position rel.position
    end
    json.relnode do
      json.id rel.related_node.id
      json.name rel.related_node.name
    end
    json.relpropinstances rel.relpropinstances do |inst|
      json.id inst.id
      json.prop_ref_id inst.ref
      json.value inst.value
      json.reltype_name inst.proptype.name
    end
  end
  json.propinstances node.propinstances do |prop|
    json.id(prop, :id)
    json.name do
      json.propid prop.property.id
      json.name prop.property.name
    end
    json.(prop, :value)
  end
end