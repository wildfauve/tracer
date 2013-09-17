Tracer::Application.routes.draw do
  root to: "nodes#index"
  
  resources :types do
    resources :type_relations
  end
  resources :reltypes
  resources :nodes do
      resources :relations
      collection do
        get 'node_form'
      end
      collection do
        get 'node_filter'
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
  
  resources :loads do
    collection do
      post 'up_load'
      post 'down_load'
    end
  end
  
  resources :compares do
    member do
      get 'attr_form'
      post 'attr_set'      
    end
  end
  
  
  resources :events do
    collection do
      post 'reset'
    end
  end
  
end
