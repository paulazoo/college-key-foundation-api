class CreateMentorsAndMentees < ActiveRecord::Migration[6.0]
  def change
    create_table :mentors do |t|
      t.timestamps
    end

    create_table :mentees do |t|

      t.timestamps
    end

    create_table :mentors_mentees do |t|
      t.references(:mentor, null: false, foreign_key: true)
      t.references(:mentee, null: false, foreign_key: true)

      t.timestamps
    end

    add_index(:mentors_mentees, %i[mentor_id mentee_id], unique: true)
  end
end
