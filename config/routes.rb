Rails.application.routes.draw do

  get 'login' => 'accounts#login'

  resources :accounts, only: %i[show update index]

  resources :mentors, only: %i[index create]

  post 'mentors/batch' => 'mentors#batch'

  resources :mentees, only: %i[index create]

  resources :mentees, param: :mentee_id do
    post 'match', on: :member
  end

  post 'mentees/batch' => 'mentees#batch'

  resources :events, only: %i[index create]

  resources :newsletter_emails, only: %i[index create]
  
end
