class UtilsController < ApplicationController
  
  def reset_all
    Type.all.delete
    Reltype.all.delete
    Node.all.delete
    Event.all.delete
    redirect_to types_path
  end
  
end

