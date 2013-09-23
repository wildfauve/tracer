class RelationsController < ApplicationController
  
  def index

  end
  
  # from compare create rel link
  # {"callback"=>["compare", "5232cc52e4df1c8b300010d9"], "other_node"=>"5232cc52e4df1c8b3000107f", 
  # "rel_type_id"=>"5232cc51e4df1c8b30000fee", "return"=>"rel_id", "node_id"=>"5237eee7e4df1cb03800002b"}
  def new
    @node = Node.find(params[:node_id])
    @other_node = Node.find(params[:other_node])
    @reltype = Reltype.find(params[:rel_type_id])
    @callback = params[:callback]    
  end
  
  def show
    @node = Node.find(params[:node_id])
  end
  
  # from node edit rel link
  # "node_id"=>"523ab8e6e4df1c06ba000003", "id"=>"523b6c04e4df1ce6ea000003"
  #
  # from compare edit rel link
  # {"callback"=>["compare", "5232cc52e4df1c8b300010d9"], "node_id"=>"523ab8bde4df1c8298000001", "id"=>"523abacde4df1cc7dc00006e"}
  # id is the relinstance id  
  def edit
    @node = Node.find(params[:node_id])
    @rel = @node.relinstances.find(params[:id])
    @callback = params[:callback]
  end
  
  
  # "callback"=>{"controller"=>"compare", "id"=>"5232cc52e4df1c8b300010d9"}, "node"=>"5237eee7e4df1cb03800002b", 
  # "other_node"=>"5232cc52e4df1c8b3000107f", "rel"=>{"type"=>"5232cc51e4df1c8b30000fee", "effect_value"=>"TEST"}, 
  # "node_id"=>"5237eee7e4df1cb03800002b"}
  def create
    # Probably this is via a NodeSet
    @ns = Nodeset.new.update_node_rel_with_new_relinstances(params)
    respond_to do |format|
      if params[:callback]
        if params[:callback][:controller] == "compare"
          format.html { redirect_to compare_path(params[:callback][:id])}
        else
          raise
        end
      else
        format.html { redirect_to node_path(@node) }
      end
    end    
  end
  
  def update
    @node = Nodeset.new.update_2(params)
    respond_to do |format|
      if params[:callback]
        if params[:callback][:controller] == "compare"
          format.html { redirect_to compare_path(params[:callback][:id])}
        else
          raise
        end
      else
        format.html { redirect_to node_path(@node) }
      end
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