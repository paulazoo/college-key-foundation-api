Rails.application.routes.draw do

  get 'login' => 'accounts#login'

  resources :accounts, only: [] do
    get 'events', on: :member
  end

  resources :accounts, only: %i[show update index]

  post 'mentors/batch' => 'mentors#batch'
  post 'mentors/master' => 'mentors#master'

  resources :mentors, only: %i[index create]

  resources :mentees, only: [] do
    post 'match', on: :member
  end

  post 'mentees/batch' => 'mentees#batch'
  post 'mentees/import' => 'mentees#import'

  resources :mentees, only: %i[index create]

  get 'events/public' => 'events#public'

  resources :events, only: [] do
    post 'register', on: :member
    post 'unregister', on: :member
    post 'public_register', on: :member
    post 'join', on: :member
    post 'public_join', on: :member
    post 'export_registered', on: :member
    post 'export_joined', on: :member
  end

  resources :events, only: %i[index create]

  resources :newsletter_emails, only: %i[index create]
  
end
