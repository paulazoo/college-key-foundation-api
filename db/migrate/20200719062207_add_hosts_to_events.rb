class AddHostsToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column(:events, :host, :string)
  end
end
