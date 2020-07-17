class Mentee < ApplicationRecord
  has_one :account, :as => :user

  has_one :mentors_mentee, dependent: :destroy
  has_one :mentor, through: :mentors_mentee

end
