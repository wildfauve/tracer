class ExportsController < ApplicationController
  
  def index
    
  end
  
  def show
    
  end
  
  def new
    params[:export_type] == "all" ? @nodes = Node.all_active : @nodes = nil
    @types = Type.all
    @reltypes = Reltype.all
    respond_to do |f|
      f.json do
        stream = render_to_string(:template=>"exports/new" )  
        send_data(stream, :type=>"application/json", :filename => "tracer_export_#{Time.now.to_s}.json")
      end
#      f.json 
    end
    
  end
  
end
