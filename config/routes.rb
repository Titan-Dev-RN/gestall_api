Rails.application.routes.draw do
  devise_for :usuarios,
  controllers: {
    sessions: 'usuarios/sessions'
  },
  path: '',
  path_names: {
    sign_in: 'login',
    sign_out: 'logout'
  }
  post "/usuarios", to: "usuarios#create"
  get "/usuarios", to: "usuarios#index" # Adicionando a rota para o método index

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  namespace :usuarios do
    devise_scope :usuario do
      post 'login', to: 'sessions#create'
      delete 'logout', to: 'sessions#destroy'
    end
  end
  namespace :api do
    namespace :v1 do
      resources :lojas do
        resources :usuarios
        resources :produtos_estoques
        resources :assinaturas
        resources :transacoes_pagamento
      end
      resources :planos
      resources :fornecedores
      resources :compradores
    end
  end
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
