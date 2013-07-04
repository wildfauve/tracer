class Archive
  
  def initialize(params)
    @ctx = params[:ctx]
    @id = params[:ctx_id]
  end
  
  def perform
    if @ctx = "node"
      @obj = Node.find(@id)
    end
    @obj.archive_perform
  end
  
end