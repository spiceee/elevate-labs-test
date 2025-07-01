Rails.application.routes.draw do
  namespace :api do
    post "/user" => "users#create"
    get "/user" => "users#show"

    post "/user/game_events" => "user/game_events#create"

    resources :sessions, only: [:new, :create, :destroy]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
