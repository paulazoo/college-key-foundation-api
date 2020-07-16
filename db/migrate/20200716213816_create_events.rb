class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string(:name)
      t.string(:description)
      t.string(:link)
      t.string(:image_url)

      t.timestamps
    end

    add_column(:events, :start_time, :datetime)
    add_column(:events, :end_time, :datetime)
    add_column(:events, :kind, :integer, default: 0)
  end
end
