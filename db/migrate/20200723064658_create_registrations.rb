class CreateRegistrations < ActiveRecord::Migration[6.0]
  def change
    create_table :registrations do |t|
      t.references(:account, null: false, foreign_key: true)
      t.references(:event, null: false, foreign_key: true)

      t.string(:ip_address)
      t.string(:public_name)
      t.string(:public_email)

      t.timestamps
    end
    
    add_column(:events, :registered, :boolean, default: false)
    add_column(:events, :joined, :boolean, default: false)
  end
end
