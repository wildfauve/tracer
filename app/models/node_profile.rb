class NodeProfile
  def initialize(profile)
    @start = profile[:start]
    @end = profile[:end]
    @rel = profile[:reltype]
  end
  
  def start
    @start[:type] ? Type.find(@start[:type]) : Node.find(@start[:node])
  end

  def end
    @end[:type] ? Type.find(@end[:type]) : nil
  end

  def rel
    Reltype.find(@rel)
  end

  
end