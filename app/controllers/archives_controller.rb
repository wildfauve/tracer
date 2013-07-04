class ArchivesController < ApplicationController
  
  def index
    @nodes = Node.all_archived    
  end
  
  def edit
    
  end

  def undelete
    a = Archive.new(params).perform
    respond_to do |format|
      format.html { redirect_to archives_path}
    end
  end
    
  
end
