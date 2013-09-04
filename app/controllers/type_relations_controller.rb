class TypeRelationsController < ApplicationController
  
  # AJAX Request to find the type of the node that has been selected.  Render a new select form
  # that changes the select form restricting it to the rels and types that are supported.
  def index
    @formctx = params[:ctx]    
    @position = params[:position] # either 'start_node' or 'end_node' or 'rel'
    if params[:context] == 'node_type'
        @type = Type.find(params[:type_id])
        @typearc = @type.find_associations(:as => @position) 
    elsif params[:context] == 'node_inst'
        @type = Node.find(params[:type_id]).type
        @typearc = @type.find_associations(:as => @position)           
    else # must be a "rel_type"
        @type = Reltype.find(params[:type_id])
        @typearc = @type.find_associations
    end
   respond_to do |format|
     #format.html {render 'node_form', :layout => false}
     format.js {render 'type_select', :layout => false }
   end       
  end 
end