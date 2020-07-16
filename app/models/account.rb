class Account < ApplicationRecord
  belongs_to :user, :polymorphic => true

  validates :email, uniqueness: true, presence: true
end
