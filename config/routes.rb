Tracer::Application.routes.draw do
  resources :types
  resources :reltypes
  resources :nodes do
      resources :relations
  end
  resources :noderelations do
    collection do
      get 'node_form'
    end
  end
  
end
