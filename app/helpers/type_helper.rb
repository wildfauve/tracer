module TypeHelper
    def type_list(type=nil, typearc=nil, position=nil, sel_pos=nil)
        if type.nil?
            @type_list || @type_list = Type.all.map{|t| [t.type_ref, t.id]}
        end
        return @type_list if @type_list && typearc.nil? # if already cached
        return [[type.type_ref, type.id ]] if position == sel_pos.to_s  # TODO, maybe return everything to allow change
        @type_list = typearc[:node_ass].map{|t| [t.type_ref, t.id]}
    end	
    
    def proptype_select
      Property.types
    end
end