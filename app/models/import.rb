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
      Event.create_event(entry: "Import#parse Working with Node: #{node["name"]}")
      if node["relinstances"].empty? # a single node without relationships
        Event.create_event(entry: "Import#parse #{node["name"]} is a Single Node")        
        Node.import(node, type_map, reltype_map, false)
      else
        Event.create_event(entry: "Import#parse #{node["name"]} has Relationships")                
        existing_node_id = nil
        node["relinstances"].each do |rel|
          if rel["reltype"]["position"] == "start"
            Event.create_event(entry: "Import#parse #{node["name"]} #{rel["reltype"]["name"]} is a Start relationship") 
            start_node = node
            end_node = find_related_node(:nodes => json["export"]["nodes"], :rel_id => rel["relnode"]["id"])
            ns = Nodeset.import(start_node, end_node, rel, type_map, reltype_map, existing_node_id)
            existing_node_id = ns.start.id.to_s
          else
            Event.create_event(entry: "Import#parse #{node["name"]} #{rel["reltype"]["name"]} is an END relationship")             
          end
        end
      end
    end
    json["export"]["compares"].each do |compare|
      Compare.import(compare)
    end
  end
  
  
  def find_related_node(params)
    params[:nodes].each do |node|
      return node if node["id"] == params[:rel_id]
    end
  end
end
    