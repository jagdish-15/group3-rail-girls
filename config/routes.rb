Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :registration, only: [:new, :create]

  resources :events do
    resources :bookings, only: [:new, :create]
  end
  resources :bookings, only: [:show, :update]

  root "events#index"
end
