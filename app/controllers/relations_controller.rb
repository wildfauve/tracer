class RelationsController < ApplicationController
  
  def index

  end
  
  def new

  end
  
  def show
    @node = Node.find(params[:node_id])
  end
  
  def edit
    @node = Node.find(params[:node_id])
    @rel = @node.relinstances.find(params[:id])
  end
  
  def create
  end
  
  def update
    @node = Node.find(params[:node_id])
    @rel = @node.relinstances.find(params[:id])
    @rel.update_rel(params)
    respond_to do |fmt|
      fmt.html { redirect_to node_path(@node) }
    end
  end
  
  def destroy
    @node = Node.find(params[:node_id])
    @node.delete_relation(params[:id])
    respond_to do |format|
      format.html { redirect_to node_path(@node) }
      format.json
    end
    
  end
    
end