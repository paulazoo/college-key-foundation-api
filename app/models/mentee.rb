class Mentee < ApplicationRecord
  has_one :account, :as => :user

  has_many :mentors_mentees, dependent: :destroy
  has_many :mentors, through: :mentors_mentees

end
