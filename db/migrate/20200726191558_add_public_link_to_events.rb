class AddPublicLinkToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column(:events, :public_link, :string)
  end
end
