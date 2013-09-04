class ComparesController < ApplicationController
  
  def index
    @compares = Compare.all
  end
  
  def new
    @compare = Compare.new
  end
  
  def show
    @compare = Compare.show_it(params)
    respond_to do |format|
      format.html
    end
  end
   
  def edit
  end
  
  def create
    @compare = Compare.create_it(params)
    respond_to do |format|
      if @compare.valid?
        format.html { redirect_to compares_path }
        format.json
      else
        format.html { render action: "new" }
        format.json
      end
    end    
  end
  
  def update
  end
  
  def destroy
    @compare = Compare.delete_it(params)
    respond_to do |format|
      if @compare.errors.blank?
        format.html { redirect_to compares_path }
        format.json
      else
        format.html { render "show" }
        format.json
      end
    end    
  end
  

end