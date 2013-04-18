class NodesController < ApplicationController
  
  def index
    @nodes = Node.all
  end
  
  def new
  end
  
  def show
    @node = Node.find(params[:id])
  end
  
  def edit
    @node = Node.find(params[:id])
  end
  
  def create

    respond_to do |format|
#      if @type.valid?
        format.html { redirect_to nodes_path }
        format.json
#      else
#        format.html { render action: "new" }
#        format.json
#      end
    end
    
  end
  
  def update
    @node = Node.find(params[:id])
    @node.update_the_node(params[:node])
    respond_to do |format|
      if @node.valid?
        format.html { redirect_to nodes_path }
        format.json
      else
        format.html { render action: "edit" }
        format.json
      end
    end
  end
  
  
end