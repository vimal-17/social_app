Rails.application.routes.draw do
  get 'ping' => 'application#ping'

  get 'health' => 'application#health'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root "posts#index"

  # Routes for Post
  get '/social/list_posts', to: 'posts#index'
  post '/social/create_post', to: 'posts#create'
  get '/social/get_post', to: 'posts#show'
  post '/social/update_post', to: 'posts#update'
  delete '/social/delete_post', to: 'posts#destroy'

  # Routes for Comments
  get '/social/list_comments', to: 'comments#index'
  post '/social/create_comment', to: 'comments#create'
  get '/social/get_comment', to: 'comments#show'
  post '/social/update_comment', to: 'comments#update'
  delete '/social/delete_comment', to: 'comments#destroy'

  # Routes for Interactions
  get '/social/list_interactions', to: 'interactions#index'
  post '/social/create_interaction', to: 'interactions#create'
  get '/social/get_interaction', to: 'interactions#show'
  post '/social/update_interaction', to: 'interactions#update'
  delete '/social/delete_interaction', to: 'interactions#destroy'

  # Routes for Group
  get '/social/list_groups', to: 'groups#index'
  post '/social/create_group', to: 'groups#create'
  get '/social/get_group', to: 'groups#show'
  post '/social/update_group', to: 'groups#update'
  delete '/social/delete_group', to: 'groups#destroy'

  # Routes for Group Users
  get '/social/list_group_users', to: 'group_users#index'
  post '/social/create_group_user', to: 'group_users#create'
  get '/social/get_group_user', to: 'group_users#show'
  post '/social/update_group_user', to: 'group_users#update'
  delete '/social/delete_group_user', to: 'group_users#destroy'

  # Routes for Users
  get '/social/list_users', to: 'users#index'
  post '/social/create_user', to: 'users#create'
  get '/social/get_user', to: 'users#show'
  post '/social/update_user', to: 'users#update'
  delete '/social/delete_user', to: 'users#destroy'


  # resources :users
  # resources :posts
  # resources :comments
  # resources :interactions
  # resources :group_users
  # resources :groups
  
  # resources :posts do
  #   resources :comments, only: [:create, :index, :show]
  #
  #   resources :interactions, only: [:create, :index, :show]
  # end


end
