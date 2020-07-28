class CorrectRegistrations < ActiveRecord::Migration[6.0]
  def change
    add_column(:registrations, :registered, :boolean, default: false)
    add_column(:registrations, :joined, :boolean, default: false)
  end
end
