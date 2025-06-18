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

  namespace :api do
    namespace :v1 do
      post 'login', to: 'sessions#create'
      delete 'logout', to: 'sessions#destroy'
      resources :fornecedores, only: [:index, :show, :create, :update, :destroy] do
        member do
          post 'reativar_fornecedor'
        end
      end
      resources :produtos, only: [:index, :show, :create, :update, :destroy] do
        member do
          post 'reativar_produto'
          post 'adicionar_estoque'
          post 'remover_estoque'
        end
        collection do
          get 'baixo_estoque'
          post 'criar_categoria'
          get 'por_categoria/:categoria', action: :por_categoria
        end
      end
      resources :clientes, only: [:index, :show, :create, :update, :destroy] do
        member do
          post 'reativar_cliente'
        end
      end
      resources :vendas, only: [:index, :show, :create] do
        collection do
          get 'vendas_all', action: :index_all
        end
        member do
          post 'atualizar_desconto_item'
          post 'adicionar_item'
          post 'aumentar_quantidade'
          delete 'remover_item/:item_id', to: 'vendas#remover_item'
          post 'finalizar'
          post 'cancelar'
        end
      end
      resources :funcionarios, only: [:index, :show, :create, :update, :destroy]
      
      resources :informacoes_lojas do
        member do
          post :reativar
        end
      end
    end
  end
end