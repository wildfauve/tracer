class Nodeset
#:start=>{:type=>"System", :implement_date=>"010101", :formal_name=>"vbz", :name=>"System1"}, 
#:end=>{:name=>"Service1"},
#:rel=>{:type=>"provides"}
  
  attr_accessor :start, :end
  
  def initialize
    @start = Node.nodefactory
    @end = Node.nodefactory
    self
  end
  
  def create(params)
    @rel = Relinstance.relfactory(params[:rel])
    @start = Node.nodefactory(params[:start]) 
    @end = Node.nodefactory(params[:end])
    @start.create_the_node(:rel => @rel, :other_node => @end)
    @end.create_the_node(:rel => @rel, :other_node => @start)
    self
  end
    
end