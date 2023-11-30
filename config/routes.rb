Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  #= <<<<< *API* >>>>>>
  namespace :api, defaults: { format: 'json' } do
    namespace :v0 do
      # -----> PASSWORDS <-----
      patch 'user/password', to: 'passwords#update'
      post 'user/password/reset', to: 'password_resets#create'

      # -----> AUTH <-----
      post 'user/auth/token/refresh', to: 'authentications#create_refresh'
      post 'user/auth/token/access', to: 'authentications#create_access'

      # -----> USER <-----
      get 'user', to: 'user#show'
      post 'user', to: 'registrations#create'
      patch 'user', to: 'user#edit'
      delete 'user', to: 'user#destroy'
      get 'user/verify', to: 'registrations#verify'
      get 'user/jobs', to: 'user#own_jobs'
      get 'user/applications', to: 'user#own_applications'
      get 'user/reviews', to: 'user#own_reviews'
      get 'user/upcoming', to: 'user#upcoming'
      delete 'user/image', to: 'user#remove_image'
      post 'user/image', to: 'user#upload_image'
      get 'user/preferences', to: 'user#get_preferences'
      patch 'user/preferences', to: 'user#update_preferences'

      post 'user/(/:id)/reviews', to: 'reviews#create'
      delete 'user/(/:id)/reviews', to: 'reviews#destroy'
      patch 'user/(/:id)/reviews', to: 'reviews#update'

      # -----> JOBS <-----
      get 'jobs', to: 'jobs#feed'
      get 'jobs/(/:id)', to: 'jobs#show'
      get 'maps', :to => 'jobs#map'
      get 'find', :to => 'jobs#find'
      post 'jobs', to: 'jobs#create'
      patch 'jobs', to: 'jobs#update'
      delete 'jobs', to: 'jobs#destroy'
      get 'jobs/(/:id)/applications', to: 'applications#show'
      get 'jobs/(/:id)/application', to: 'applications#show_single'
      post 'jobs/(/:id)/applications', to: 'applications#create'
      patch 'jobs/(/:id)/applications/(/:application_id)/accept', to: 'applications#accept'
      patch 'jobs/(/:id)/applications/(/:application_id)/reject', to: 'applications#reject'

      # get 'jobs/(/:id)/applications/(/:user)/accept', to: 'applications#accept'
      # patch 'jobs/(/:id)/applications/(/:user)/accept', to: 'applications#accept'
      # delete 'jobs/(/:id)/applications', to: 'applications#destroy'

      # -----> QUICKLINK <-----
      post 'quick/token/client', to: 'quicklink#create_client'
      post 'quick/token/request', to: 'quicklink#create_request'
      post 'quick/applications', to: 'quicklink#apply'

      # -----> GENIUS-QUERIES <-----
      get 'resource/(/:genius)', to: 'genius_queries#query'
      post 'resource', to: 'genius_queries#create'

    end
  end
end

