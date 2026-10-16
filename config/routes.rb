Rails.application.routes.draw do
  root to: 'splash_page#index'
  get '/home', to: 'home#index', as: :home

  mount ShopifyApp::Engine, at: '/'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/home_generate', to: 'home#generate'
  get '/search', to: 'promo_codes#search'

  resources :promo_code_generates, only: [:new, :create]
  resources :reports, only: [:index, :create]
  resources :shop_settings, only: [:edit, :update]

  resources :promo_codes, only: [:create, :destroy, :edit, :update, :index] do
    collection do
      post :lookup
      post :update_usage_limit
      post :update_usage_limit_exhausted_only
      get :generate
      get :generate_used_code
      get :generate_unused_code
      get :generate_exhausted_code
      get :generate_expired_code
    end
  end

  resources :themes, only: [] do
    collection do
      get :modification_instructions
      get :download_file
      post :modify
      post :create_code_pages
    end
  end

  resource :shop_store_front, only: [] do
    collection do
      post :validate_code
      get :fetch_products
      get :order_validity_status
      post :orders
      get :states
    end
  end

end
