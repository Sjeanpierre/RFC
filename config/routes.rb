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
  root 'pages#home'

end
