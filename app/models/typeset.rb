class Typeset
# {"start"=>{"type"=>"51dcdea1e4df1c44c00000d3"}, 
# "rel"=>{"type"=>"51df95fbe4df1c89a6000048"}, 
# "end"=>{"type"=>"51dcdea1e4df1c44c00000d6"}}  
  attr_accessor :start_type, :end_type, :rel_type
    
  def load(params)
    @start_type = Type.factory(params[:start])
    @rel_type = Reltype.factory(params[:rel])
    @end_type = Type.factory(params[:end])
    self
  end
  
  def standardise_name
    s = @start_type.type_ref.gsub(/ /, '-')
    r = @rel_type.name.gsub(/ /, '-')
    e = @end_type.type_ref.gsub(/ /, '-')        
    s + "->" + r + "->" + e
  end
  
    
end