class NodeProfile
  def initialize(profile)
    @start = profile[:start]
    @end = profile[:end]
    @rel = profile[:reltype]
  end
  
  def start
    Type.find(@start)
  end

  def end
    Type.find(@end)
  end

  def rel
    Reltype.find(@rel)
  end

  
end