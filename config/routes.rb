Rails.application.routes.draw do

  get 'login' => 'accounts#login'

  resources :accounts, only: %i[show index]

  resources :mentors, only: %i[index create]

  resources :mentees, only: %i[index create]
  
end
