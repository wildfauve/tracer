class Export
  
  attr_accessor :nodes, :types, :reltypes, :file_name, :compares
  
  def initialize(args)
    @template = args[:is_template]
    @name = args[:project_name]
    self.template_only? ? @nodes = nil : @nodes = Node.all_active
    @types = Type.all
    @reltypes = Reltype.all
    @compares = Compare.all
  end
  
  def template_only?
    @template == "yes" ? true : false
  end
  
  
  def file_name
    "#{@name}-#{"template" if self.template_only?}-#{Time.now.to_s}.json"
  end
  
end