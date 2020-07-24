class Registration < ApplicationRecord
  belongs_to :account, optional: true
  belongs_to :event
end
