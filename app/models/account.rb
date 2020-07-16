class Account < ApplicationRecord
  belongs_to :user, :polymorphic => true

  validates :email, uniqueness: true, presence: true

  has_many :invitations, class_name: 'Invitation', foreign_key: 'account_id'
  has_many :invited_events, through: :invitations, source: :event
end
