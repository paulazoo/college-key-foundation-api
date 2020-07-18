class Event < ApplicationRecord
  enum kind: { open: 0, invite_only: 1 }
  
  has_many :invitations, class_name: 'Invitation', foreign_key: 'event_id', dependent: :destroy

  validates_presence_of :name

end
