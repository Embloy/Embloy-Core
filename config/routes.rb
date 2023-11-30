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

  #= <<<<< *Web-Application* >>>>>>
  # -----> Homepage <-----
  root 'welcome#index', as: :root
  get 'about', :to => 'welcome#about', as: :about
  get 'about/privacy_policy', :to => 'welcome#privacy_policy', as: :privacy_policy
  get 'about/cookies', :to => 'welcome#cookies', as: :cookies
  get 'about/termsofservice', :to => 'welcome#terms_of_service', as: :terms_of_service
  get 'about/help', :to => 'welcome#help', as: :help
  get 'about/api', :to => 'welcome#api', as: :api
  get 'about/api/apidoc.json', :to => 'welcome#apidoc', as: :apidoc
  get 'about/faq', :to => 'welcome#faq', as: :faq

  # -----> Jobs & Applications <-----
  resources :jobs do
    resources :applications
  end
  patch 'jobs/(/:job_id)/applications/(/:application_id)/accept', :to => 'applications#accept', as: :job_application_accept
  patch 'jobs/(/:job_id)/applications/(/:application_id)/reject', :to => 'applications#reject', as: :job_application_reject
  patch 'jobs/(/:job_id)/applications_reject_all', :to => 'applications#reject_all', as: :job_applications_reject_all
  delete 'jobs/(/:job_id)/applications/(/:application_id)' => 'applications#destroy'
  delete 'jobs/(/:id)/remove_image', :to => 'jobs#remove_image', as: :remove_job_image

  get 'reviews', :to => 'reviews#index', as: :reviews
  get 'reviews/(/:user_id)', :to => 'reviews#for_user', as: :reviews_user
  post 'reviews', :to => 'reviews#index'

  # -----> Map <-----
  get 'jobs_maps', :to => 'jobs#map', as: :jobs_map
  post 'jobs_maps/update_jobs', :to => 'jobs#update_jobs', as: :jobs_map_update_jobs

  # -----> Feed-Generator <-----
  get 'find_jobs', :to => 'jobs#find', as: :jobs_find
  post 'find_jobs', :to => 'jobs#parse_inputs'

  # -----> Authentication & Authorization <-----
  get 'sign_up', to: 'registrations#new'
  post 'sign_up', to: 'registrations#create'
  get 'sign_in', to: 'sessions#new'
  post 'sign_in', to: 'sessions#create', as: :log_in
  get 'verify', to: 'registrations#verify_account', as: :verify_account
  get 'activate', to: 'registrations#activate_account', as: :activate_account
  delete 'logout', to: 'sessions#destroy'

  get "/auth/github/callback", to: 'oauth_callbacks#github', as: :auth_github_callback
  get "/auth/google_oauth2/callback", to: 'oauth_callbacks#google', as: :auth_google_callback

  get 'password', to: 'passwords#edit', as: :edit_password
  patch 'password', to: 'passwords#update'
  get 'password/reset', to: 'password_resets#new'
  post 'password/reset', to: 'password_resets#create'
  get 'password/edit', to: 'password_resets#edit', as: :password_reset_edit
  patch 'password/edit', to: 'password_resets#update', as: :password_reset_update

  # -----> User management <-----
  # get 'user/', :to => 'user#index', as: :user_index
  get 'user/profile', :to => 'user#index', as: :profile_index
  # TODO: @cb check duplicate routes
  patch 'user/profile', :to => 'user#update', as: :user
  patch 'user/profile', to: 'user#update', as: :profile_update
  patch 'user/update_location', :to => 'user#update_location', as: :user_update_location
  delete 'user', to: 'user#destroy', as: :user_delete
  delete 'user/remove_image', to: 'user#remove_image', as: :remove_user_image
  get 'user/edit', :to => 'user#edit', as: :profile_edit
  get 'user/settings', :to => 'user#settings', as: :profile_settings
  get 'user/applications', :to => 'user#own_applications', as: :own_applications
  get 'user/jobs', :to => 'user#own_jobs', as: :own_jobs
  get 'user/preferences', to: 'user#preferences', as: :preferences
  patch 'user/preferences', to: 'preferences#update', as: :preferences_update
  post 'user/preferences', to: 'preferences#update', as: :preferences_create
end