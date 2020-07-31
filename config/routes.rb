Rails.application.routes.draw do

  get 'login' => 'accounts#login'

  put 'accounts/master_update' => 'accounts#master_update'

  resources :accounts, only: [] do
    get 'events', on: :member
    post 'mail', on: :member
  end

  resources :accounts, only: %i[show update index]

  post 'mentors/batch' => 'mentors#batch'
  post 'mentors/master' => 'mentors#master'

  resources :mentors, only: %i[index create]

  resources :mentees, only: [] do
    post 'match', on: :member
    post 'unmatch', on: :member
  end

  post 'mentees/batch' => 'mentees#batch'

  resources :mentees, only: %i[index create]

  get 'events/public' => 'events#public'

  resources :events, only: [] do
    post 'register', on: :member
    post 'unregister', on: :member
    post 'public_register', on: :member
    post 'join', on: :member
    post 'public_join', on: :member
  end

  resources :events, only: %i[index create update destroy]

  resources :newsletter_emails, only: %i[index create]
  
  post 'google_sheets/import_mentee_mentor' => 'google_sheets#import_mentee_mentor'
  post 'google_sheets/import_events' => 'google_sheets#import_events'
  post 'google_sheets/export_registered' => 'google_sheets#export_registered'
  post 'google_sheets/export_joined' => 'google_sheets#export_joined'


end
