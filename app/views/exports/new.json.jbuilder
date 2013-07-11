json.export do |json|
  json.partial! 'types/show', :types => @types
  json.partial! 'reltypes/show', :reltypes => @reltypes
  json.partial! 'nodes/show', :nodes => @nodes
end