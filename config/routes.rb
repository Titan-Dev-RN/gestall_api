Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Rotas de autenticação principal (Devise)
  devise_for :usuarios,
    controllers: {
      sessions: 'usuarios/sessions',
      registrations: 'usuarios/registrations'
    },
    path: '',
    path_names: {
      sign_in: 'login',
      sign_out: 'logout',
      registration: 'cadastro'
    }

  # Rotas adicionais de usuários
  resources :usuarios, only: [:index, :create]

  # Namespace para API
  namespace :api do
    namespace :v1 do
      # Autenticação da API (usando sessions_controller)
      post 'login', to: 'sessions#create'
      delete 'logout', to: 'sessions#destroy'

      # Rotas para o estoque (products_controller)
      resources :produtos, only: [:index, :show, :create, :update, :destroy] do
        collection do
          get 'baixo_estoque'
          get 'por_categoria/:categoria', action: :por_categoria
        end
      end
  
      # Rotas para vendas (vendas_controller)
      resources :vendas, only: [:index, :show, :create] do
        collection do
          get 'vendas_all', action: :index_all
        end
        member do
          post 'adicionar_item'
          delete 'remover_item/:item_id', to: 'vendas#remover_item'
          post 'finalizar'
          post 'cancelar'
        end
      end
  
      # Relatórios (podem ficar no base_controller ou criar um relatorios_controller)
      get 'relatorios/estoque', to: 'base#relatorio_estoque'
      get 'relatorios/vendas', to: 'base#relatorio_vendas'
    end
  end
end