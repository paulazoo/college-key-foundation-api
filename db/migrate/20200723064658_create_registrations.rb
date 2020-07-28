class CreateRegistrations < ActiveRecord::Migration[6.0]
  def change
    create_table :registrations do |t|
      t.references(:account, null: true, foreign_key: true)
      t.references(:event, null: false, foreign_key: true)

      t.string(:ip_address)
      t.string(:public_name)
      t.string(:public_email)

      t.timestamps
    end
    
  end
end
