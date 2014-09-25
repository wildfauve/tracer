class TypesController < ApplicationController
  
  def index
    @types = Type.all.sort(:type_ref => :asc)
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
    type = Type.new
    type.subscribe(self)
    type.create_me(type: params[:type])
  end

  def update
    type = Type.find(params[:id])
    type.subscribe(self)
    type.update_the_type(type: params[:type])
  end


  def destroy
    type = Type.find(params[:id])
    type.subscribe(self)
    type.delete_me
  end

  def successful_create(type)
    redirect_to types_path
  end
  
  def successful_delete(type)
    redirect_to types_path
  end
  
  def error_delete(type)
    @type = type
    render 'show'
  end

end
