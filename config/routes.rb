Rails.application.routes.draw do
  root "products#index"

  # Vitrine e catálogo (US-004, US-005, US-006)
  resources :products, only: %i[index show], path: "cupcakes"

  # Cliente: cadastro, login, logout (US-001, US-002, US-003)
  get    "cadastro", to: "registrations#new",  as: :signup
  post   "cadastro", to: "registrations#create"
  get    "entrar",   to: "sessions#new",       as: :login
  post   "entrar",   to: "sessions#create"
  delete "sair",     to: "sessions#destroy",   as: :logout

  # Carrinho (US-007, US-008, US-009)
  resource :cart, only: :show, path: "carrinho" do
    post   "itens",      to: "carts#add",    as: :add
    patch  "itens/:id",  to: "carts#update", as: :update
    delete "itens/:id",  to: "carts#remove", as: :remove
    post   "cupom",      to: "carts#apply_coupon", as: :coupon
  end

  # Checkout, pagamento, pedidos (US-010, US-011, US-012, US-018, US-019)
  get  "checkout", to: "checkouts#new", as: :checkout
  post "checkout", to: "checkouts#create"
  resources :addresses, only: %i[new create], path: "enderecos"
  resources :orders, only: %i[index show], path: "pedidos" do
    patch :cancel, on: :member
    resources :reviews, only: :create, path: "avaliacoes" # US-013
  end

  # Painel administrativo
  namespace :admin do
    root "dashboard#index"
    get    "entrar",   to: "sessions#new",      as: :login
    post   "entrar",   to: "sessions#create"
    delete "sair",     to: "sessions#destroy",  as: :logout
    get    "cadastro", to: "registrations#new", as: :signup   # US-021
    post   "cadastro", to: "registrations#create"

    resources :products, path: "cupcakes" do                # US-014
      patch :stock, on: :member                               # US-015
    end
    resources :categories, only: %i[index create destroy], path: "categorias"
    resources :orders, only: %i[index show], path: "pedidos" do # US-016
      patch :advance, on: :member
      patch :cancel, on: :member
    end
    resources :coupons, except: :show, path: "cupons"        # US-020
    resources :reviews, only: %i[index update destroy], path: "avaliacoes"
    resources :users, only: :index, path: "administradores" do
      patch :approve, on: :member
      patch :unlock, on: :member
    end
    get "relatorios", to: "reports#index", as: :reports      # US-017
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
