class Nodeset
#:start=>{:type=>"System", :implement_date=>"010101", :formal_name=>"vbz", :name=>"System1"}, 
#:end=>{:name=>"Service1"},
#:rel=>{:type=>"provides"}
  
  def initialize(params)
    @rel = Relinstance.relfactory(params[:rel])
    @start = Node.nodefactory(params[:start]) 
    @end = Node.nodefactory(params[:end])
    @start.create_the_node(:rel => @rel, :other_node => @end)
    @end.create_the_node(:rel => @rel, :other_node => @start)
  end
    
end