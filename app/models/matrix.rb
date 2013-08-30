class Matrix
  
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  field :name, :type => String
  field :x, type: Moped::BSON::ObjectId
  field :y, type: Moped::BSON::ObjectId
  
end