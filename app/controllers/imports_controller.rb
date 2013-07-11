class ImportsController < ApplicationController
  
  def index
  end
  
  def new
    
  end
  
  def create
    name = params[:import].original_filename
    directory = "public/imports"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(params[:import].tempfile.read) }
    flash[:notice] = "File uploaded"
    @import = Import.new(path).parse
    redirect_to imports_path
  end
  
end