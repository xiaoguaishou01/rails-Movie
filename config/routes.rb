Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'movies#index'
  resources :movies do
    member do
      post :favorite
      post :cancel
    end
    resources :reviews
  end
end
