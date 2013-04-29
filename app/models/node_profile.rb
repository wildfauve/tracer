class NodeProfile
  
  attr_accessor :start_inst, :end_inst, :rel, :start_type, :end_type
  
  def initialize(profile)
    self.start = profile[:start]
    self.end = profile[:end]
    self.rel = profile[:reltype]
#    self.create_if_instances  # if these are instances, just create them; TODO: What about editing properties
  end
  
  def start=(profile)
    if profile.nil?
      @end_type = nil
      @end_inst = nil
      return
    end
    if profile[:type]
      @start_type = Type.find(profile[:type])
    else
      @start_inst = Node.find(profile[:inst])
      @start_type = @start_inst.type
    end
  end

  def end=(profile)
    if profile.nil?
      @end_type = nil
      @end_inst = nil
      return
    end
    if profile[:type]
      @end_type = Type.find(profile[:type])
    else
      @end_inst = Node.find(profile[:inst])
      @end_type = @end_inst.type
    end
  end

  def rel=(id)
    !id.nil? ? @rel = Reltype.find(id) : @rel = nil
  end

  def create_if_instances
    if @start_inst && @end_inst
      rel = Relinstance.relfactory({:type => @rel.id})
      @start_inst.create_the_node(:rel => rel, :other_node => @end_inst)
      @end_inst.create_the_node(:rel => rel, :other_node => @start_inst)      
    end
  end
end