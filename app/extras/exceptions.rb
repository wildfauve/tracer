module Exceptions
  
  class Standard < StandardError 
    attr :errorcode
    
    def intialize
      @errorcode = 1000
    end
  
  end
  
  
  class TypeHasTypeRel < Standard
    def message
      "The Type cannot be archived because it has Type Relationships attached"
    end
  end

end