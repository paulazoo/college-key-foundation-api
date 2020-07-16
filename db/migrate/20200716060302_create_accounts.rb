class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.string(:google_id)
      t.string(:name)
      t.string(:email)
      t.string(:image_url)
      t.string(:token)
      t.string(:display_name)
      t.string(:given_name)
      t.string(:family_name)
      t.string(:phone)
      t.string(:bio)

      t.references(:user, polymorphic: true)

      t.timestamps
    end
  end
end
