json.export do |json|
  json.partial! 'types/show', :types => @export.types
  json.partial! 'reltypes/show', :reltypes => @export.reltypes
  json.partial! 'nodes/show', :nodes => @export.nodes
  json.partial! 'compares/show', :compares => @export.compares
end