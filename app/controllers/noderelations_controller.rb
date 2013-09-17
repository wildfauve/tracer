class NoderelationsController < ApplicationController
  
  def new
    @nodeset = Nodeset.new
    @formctx = params[:form_ctx]
    if params[:start_node]
        @start_node = Node.find(params[:start_node])
    end
  end
  
  def edit
    @node = Node.find(params[:id])
  end
  
  def create
    @nodeset = Nodeset.new.create(params)
    Rails.logger.info(">>>NodeController#create  Valid?  #{@nodeset.start.valid?} #{@nodeset.end.valid?} ")    
    respond_to do |format|
      if @nodeset.start.valid? && @nodeset.end.valid?
        format.html { redirect_to node_path(@nodeset.start) }
        format.json
      else
        format.html { render action: "new" }
        format.json
      end
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
  
  def node_form
    @profile = NodeProfile.new(params[:node_profile])
    respond_to do |format|
      #format.html {render 'node_form', :layout => false}
      format.js {render 'node_form', :layout => false }# 
    end
  end
  
  def accumulate_node_form
    Rails.logger.info(">>>NodeController#accum  #{params.inspect}")        
    @formctx = params[:node_profile][:ctx]
    @profile = NodeProfile.new(params[:node_profile])
    respond_to do |format|
      #format.html {render 'node_form', :layout => false}
      format.js {render 'node_form', :layout => false }# 
    end  
  end
  
  def reset_form
    Rails.logger.info(">>>NodeController#reset  #{params.inspect}")            
    @formctx = params[:form_ctx]    
    respond_to do |format|
      format.html {redirect_to  new_noderelation_path(form_ctx: @formctx)}
    end
  end
  
end