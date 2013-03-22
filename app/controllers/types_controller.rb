class TypesController < ApplicationController
  
  def index
    @types = Type.all
  end
  
  def show
    @type = Type.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
    end    
  end
  
  def new
    @type = Type.new
    3.times {@type.properties.build}
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /types/1/edit
  def edit
    @type = Type.find(params[:id])
  end

  # POST /types
  # POST /types.json
  def create
    Rails.logger.info(">>>Type Controller>>CREATE: #{params.inspect}, #{request.format}")
    @type = Type.create_the_type(params[:type])
    respond_to do |format|
      if @type.valid?
        format.html { redirect_to types_path }
        format.json
      else
        format.html { render action: "new" }
        format.json
      end
    end
  end
  
  
end
