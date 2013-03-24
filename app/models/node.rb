class Node
  
  include Mongoid::Document
  
  field :ref, :type => String
  
  embeds_many :propinstances
  
  
  # NEO4J Class
end