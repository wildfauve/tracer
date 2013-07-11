class Export
  
  def self.generate
    Type.all do |type|
      jsontype += type.generate
    end
    jsontype
  end
  
end
