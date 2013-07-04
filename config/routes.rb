Tracer::Application.routes.draw do
  resources :types do
    resources :type_relations
  end
  resources :reltypes
  resources :nodes do
      resources :relations
      collection do
        get 'node_form'
      end
  end
  resources :noderelations do
    collection do
      get 'node_form'
      get 'accumulate_node_form'
      get 'reset_form'
    end
  end
  
  resources :archives do
    collection do
      put 'undelete'
    end
  end
  
  
end
