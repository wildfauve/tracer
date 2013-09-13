class LoadsController < ApplicationController
  
  def index
    
  end
  
  def show
    
  end
  
  def new
    params[:type] == "save" ? @render_form = "save_form" : @render_form = "load_form"
    respond_to do |f|
      f.js {render 'form', :layout => false }
    end
  end
  
  def download
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
  
  def up_load
    name = params[:import].original_filename
    directory = "public/imports"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(params[:import].tempfile.read) }
    flash[:notice] = "File uploaded"
    @import = Import.new(path).parse
    redirect_to types_path
  end
  
  def down_load
    @export = Export.new(params)
    respond_to do |f|
      f.json do
        stream = render_to_string(template: "loads/down_load" )  
        send_data(stream, :type=>"application/json", :filename => @export.file_name)
      end
    end
  end
  
  
end
