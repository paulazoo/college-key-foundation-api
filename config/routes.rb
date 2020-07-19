Rails.application.routes.draw do

  get 'login' => 'accounts#login'

  resources :accounts, only: %i[show update index]

  resources :mentors, only: %i[index create]

  resources :mentees, only: %i[index create]

  resources :mentees, param: :mentee_id do
    post 'match', on: :member
  end

  resources :events, only: %i[index create]

  resources :newsletter_emails, only: %i[index create]
  
end
