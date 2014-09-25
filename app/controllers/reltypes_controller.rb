class ReltypesController < ApplicationController
  
  def index
    @rels = Reltype.all
  end
  
  def show
    @rel = Reltype.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
    end    
  end
  
  def new
    @rel = Reltype.new
    respond_to do |format|
      format.html # new.html.erb
    end

  end

  # GET /rels/1/edit
  def edit
    @rel = Reltype.find(params[:id])
  end

  # POST /rels
  # POST /rels.json
  def create
    rel = Reltype.new
    rel.subscribe(self)
    rel.create_me(reltype: params[:reltype])
  end

  def update
    reltype = Reltype.find(params[:id])
    reltype.subscribe(self)
    reltype.update_me(reltype: params[:reltype])
  end


  def destroy
    @rel = Reltype.find(params[:id])
    @rel.remove_the_reltype
    respond_to do |format|
      if @rel.errors.blank?
        format.html { redirect_to reltypes_path }
        format.json
      else
        format.html { render action: "show" }
        format.json
      end
    end
  end
  
  def successful_create(reltype)
    redirect_to reltypes_path
  end
  
end
