# == Route Map (Updated 2014-06-12 14:45)
#
#       Prefix Verb   URI Pattern               Controller#Action
#         root GET    /                         static_pages#home
# tweets_track GET    /tweets/track(.:format)   tweets#track
# tweets_graph GET    /tweets/graph(.:format)   tweets#graph
# tweets_check GET    /tweets/check(.:format)   tweets#check
# tweets_start GET    /tweets/start(.:format)   tweets#start
# tweets_store GET    /tweets/store(.:format)   tweets#store
#  tweets_stop GET    /tweets/stop(.:format)    tweets#stop
#       signup GET    /signup(.:format)         users#new
#         help GET    /help(.:format)           static_pages#help
#      contact GET    /contact(.:format)        static_pages#contact
#       signin GET    /signin(.:format)         sessions#new
#      signout DELETE /signout(.:format)        sessions#destroy
#     sessions POST   /sessions(.:format)       sessions#create
#  new_session GET    /sessions/new(.:format)   sessions#new
#      session DELETE /sessions/:id(.:format)   sessions#destroy
#       tracks POST   /tracks(.:format)         tracks#create
#        track DELETE /tracks/:id(.:format)     tracks#destroy
#        users GET    /users(.:format)          users#index
#              POST   /users(.:format)          users#create
#     new_user GET    /users/new(.:format)      users#new
#    edit_user GET    /users/:id/edit(.:format) users#edit
#         user GET    /users/:id(.:format)      users#show
#              PATCH  /users/:id(.:format)      users#update
#              PUT    /users/:id(.:format)      users#update
#              DELETE /users/:id(.:format)      users#destroy
#

Tweetwatch::Application.routes.draw do
  root 'static_pages#home'

  # match '/tweets/track', :to => 'tweets#track', via: 'get'
  # match '/tweets/graph', :to => 'tweets#graph', via: 'get'
  # match '/tweets/check', :to => 'tweets#check', via: 'get'
  # match '/tweets/start', :to => 'tweets#start', via: 'get'
  # match '/tweets/store', :to => 'tweets#store', via: 'get'
  # match '/tweets/stop',  :to => 'tweets#stop',  via: 'get'
  resources :tweets, except: [:index, :create, :new, :show, :edit, :update, :destroy] do
    member do
      get 'check'
      get 'start'
      get 'store'
      get 'stop'
      get 'track'
      get 'graph'
    end
  end

  match '/signup',  to: 'users#new',            via: 'get'
  match '/help',    to: 'static_pages#help',    via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
  resources :sessions, only: [:new, :create, :destroy]
  resources :tracks, only: [:create, :destroy]
  resources :users
  match '*not_found' => 'application#render_404', via: 'get'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
