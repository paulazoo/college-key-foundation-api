class Event < ApplicationRecord
  enum kind: { open: 0, fellows_only: 2, invite_only: 2 }
  
  has_many :invitations, class_name: 'Invitation', foreign_key: 'event_id', dependent: :destroy

  has_many :registrations, class_name: 'Registration', foreign_key: 'event_id', dependent: :destroy

  validates_presence_of :name

end
