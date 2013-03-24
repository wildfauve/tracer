class Propinstance
  
  include Mongoid::Document
  
  field :ref, :type => String

  embedded_in :node, :inverse_of => :propinstances

end