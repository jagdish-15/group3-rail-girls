Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :registration, only: [:new, :create]

  resources :events, only: [:index, :show] do
    resources :bookings, only: [:new, :create]
  end
  resources :bookings, only: [:index, :show, :update] do
    member do
      patch :cancel
      get :refund
    end
  end

  root "events#index"
end
