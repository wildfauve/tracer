class Import
  
  def initialize(path)
    @path = path
    self
  end
  
  def parse
    json = ActiveSupport::JSON.decode(File.open(@path).read)
    # import types
    type_map = {}
    json["export"]["types"].each {|type| type_map[type["id"]] = Type.import(type).id }
    # import reltypes
    reltype_map = {}
    json["export"]["reltypes"].each {|rt| reltype_map[rt["id"]] = Reltype.import(rt,type_map).id }
    json["export"]["nodes"].each do |node|
      node["relinstances"].empty? ? Node.import(node, type_map, reltype_map) : Nodeset.import(node, node, type_map, reltype_map)
    end
  end
  
end
    