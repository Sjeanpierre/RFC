Starterapp::Application.routes.draw do
  get "change/show"
  get "change/new"
  match '/auth/:service/callback' => 'services#create', via: %i(get post)
  match '/auth/failure' => 'services#failure', via: %i(get post)
  match '/logout' => 'sessions#destroy', via: %i(get delete), as: :logout
  match '/login' => 'sessions#new', via: %i(get), as: :login
  get '/new' => 'change#new'
  resources :change
  resources :services, only: %i(index create destroy)
  #root 'pages#home'
  root 'change#index'
  match '/:resource/add' => 'change#add_resource', :via => 'post'
  match '/change/approve/:id' => 'change#approve', :via => 'post'
  match '/change/reject/:id' => 'change#reject', :via => 'post'
  match '/:resource/list' => 'change#get_resource', :via => 'get'
end
