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
    @type = Type.create_the_type(params[:type])
    respond_to do |format|
      if @type.valid?
        format.html { redirect_to types_path }
        format.json
      else
        Rails.logger.info(">>>Type Controller>>CREATE/error: #{@type.errors.inspect}")        
        format.html { render action: "new" }
        format.json
      end
    end
  end

  def update
    @type = Type.find(params[:id])
    @type.update_the_type(params[:type])
    respond_to do |format|
      if @type.valid?
        format.html { redirect_to types_path }
        format.json
      else
        format.html { render action: "edit" }
        format.json
      end
    end
  end


  def destroy
    @type = Type.find(params[:id])
    @type.delete
    Rails.logger.info(">>>TypeController#delete #{@type.errors.inspect} ")
    respond_to do |format|
      if @type.errors.blank?
        format.html { redirect_to types_path }
        format.json
      else
        format.html { render "show" }
        format.json
      end
    end
  end

end
