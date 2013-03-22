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
    3.times {@rel.properties.build}
    @rel.arcprop = Arcprop.new
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
    @rel = Reltype.create_the_reltype(params[:reltype])
    respond_to do |format|
      if @rel.valid?
        format.html { redirect_to reltypes_path }
        format.js
        format.json
      else
        format.html { render action: "new" }
        format.js { render "create_errors" }
        format.json
      end
    end
  end

  def destroy
    @rel = Reltype.find(params[:id])
    @rel.destroy
    respond_to do |format|
      if @rel.valid?
        format.html { redirect_to reltypes_path }
        format.js
        format.json
      else
        format.html { render action: "new" }
        format.js { render "create_errors" }
        format.json
      end
    end
    
  end
  
end
