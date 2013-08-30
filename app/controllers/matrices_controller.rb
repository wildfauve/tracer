class MatricesController < ApplicationController
  
  def index
    @matrices = Matrix.all
  end
  
  def new
    @matrix = Matrix.new
  end
  
  def show
  end
   
  def edit
  end
  
  def create
  end
  
  def update
  end
  
  def destroy
  end
  

end