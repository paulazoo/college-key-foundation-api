class AddClassroomToMentees < ActiveRecord::Migration[6.0]
  def change
    add_column(:mentees, :classroom, :string)
  end
end
