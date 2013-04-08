class Relpropinstance
  include Mongoid::Document
  
  field :ref, :type => String
  field :value, :type => String

  embedded_in :relation, :inverse_of => :propinstances
  
end