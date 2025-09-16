Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'health', to: 'health#index'

      namespace 'auth' do
        post 'register'
        post 'login'
        delete 'logout'
        get 'me'
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
