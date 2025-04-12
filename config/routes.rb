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
  get "/usuarios", to: "usuarios#index"

  namespace :usuarios do
    devise_scope :usuario do
      post 'login', to: 'sessions#create', as: :usuario_login
      delete 'logout', to: 'sessions#destroy', as: :usuario_logout
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

  get "up" => "rails/health#show", as: :rails_health_check
end