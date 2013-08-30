class NodesController < ApplicationController
  
  def index
    if params[:filter_type].present?
      @nodes = Type.find(params[:filter_type]).nodes
    else
      @nodes = Node.all_active
    end
  end
  
  # create a new node, without creating a node relationship.
  # OK this is a little recursive.  A new_node_path without params (to create a new node) resolves here.
  # But, we then need to present a form that selects what the new node type is (to display the right properties)
  # and this means we need to :GET this again, but this time with a node Type id set.
  def new
    if params[:node]
      @node_type = Type.find(params[:node])
      respond_to do |format|
        format.html { render 'new_node_with_type'}
      end
    else
      respond_to do |format|
        format.html { render 'new'}
      end      
    end      
      
  end
  
  def show
    @node = Node.find(params[:id])
  end
   
  def edit
    @node = Node.find(params[:id])
  end
  
  def create
    @node = Node.nodefactory(params).create_the_node
    respond_to do |format|
    if @node.valid?
      format.html { redirect_to nodes_path }
      format.json
    else
      format.html { render action: "new" }
      format.json
    end
  end
    
  end
  
  def update
    @node = Node.nodefactory(params, nil, params[:id]).update_the_node
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
  
  def destroy
    @node = Node.find(params[:id])
    @node.remove_the_node
    respond_to do |format|
      if @node
        format.html { redirect_to nodes_path }
        format.json
      else
        format.html { render action: "edit" }
        format.json
      end
    end
  end
  
  def node_form  # get a single node form
    @node_type = Type.find(params[:node_type])
    respond_to do |format|
      format.js {render 'node_form', :layout => false }# 
    end
  end
  
  def node_filter
    respond_to do |format|
      format.html {redirect_to nodes_path}
    end
  end
  
end