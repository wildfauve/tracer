Tracer::Application.routes.draw do
  resources :types
  resources :reltypes
  resources :nodes do
    collection do
      get 'node_form'
    end
  end
  
end
