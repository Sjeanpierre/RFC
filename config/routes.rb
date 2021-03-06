Rfc::Application.routes.draw do
  get 'change/show'
  get 'change/new'
  get 'change/print_report'
  get 'change/report'
  match '/auth/:service/callback' => 'services#create', via: %i(get post)
  match '/auth/failure' => 'services#failure', via: %i(get post)
  match '/logout' => 'sessions#destroy', via: %i(get delete), as: :logout
  match '/login' => 'sessions#new', via: %i(get), as: :login
  get '/new' => 'change#new'
  resources :change
  resources :services, only: %i(index create destroy)
  #root 'pages#home'
  #Settings routes
  match '/:resource/add' => 'settings#add_resource', :via => 'post'
  match 'change/settings/:setting_area' => 'settings#settings', :via => 'get'
  match '/change/settings/render/:settings_area' => 'settings#render_settings_area', :via => 'get'
  #end settings
  root 'change#index'
  match '/change/:id/attach' => 'change#add_attachment', :via => 'post'
  match '/change/:id/comment' => 'change#comment', :via => 'post'
  match '/change/approve/:id' => 'change#approve', :via => 'post'
  match '/change/reject/:id' => 'change#reject', :via => 'post'
  match '/change/complete/:id' => 'change#complete', :via => 'post'
  match '/change/:id/:resource/update' => 'change#update', :via => 'post'
  match '/:resource/list' => 'change#get_resource', :via => 'get'
  match '/:resource/items' => 'change#get_resources', :via => 'get'
  match '/:resource/count' => 'change#count', :via => 'get'
  match '/change/:id/render/:partial' => 'change#render_partial', :via => 'get'
  match '/change/:cid/attachment/:aid' => 'change#download', :via => 'get'
  match '/change/render/report' => 'change#print_data', :via => 'post'
  #API routes
  match 'api/changes/list' => 'api#list', :via => 'get'
  match 'api/changes/:id' => 'api#show', :via => 'get'
end
