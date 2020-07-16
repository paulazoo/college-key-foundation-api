Rails.application.routes.draw do

  get 'login' => 'accounts#login'

  resources :accounts, only: %i[show index]
  
end
