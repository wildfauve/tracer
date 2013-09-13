json.compares compares do |compare|
  json.(compare, :id)
  json.(compare, :name)
  json.start do
    json.type do 
      json.type_ref compare.axis_title(axis: :x)
    end
  end
  json.end do
    json.type do 
      json.type_ref compare.axis_title(axis: :y)
    end
  end
  json.rel do
    json.type do 
      json.type_ref compare.relation_title
    end
  end
end
