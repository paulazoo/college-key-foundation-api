class AddSchoolAndGradYear < ActiveRecord::Migration[6.0]
  def change
    add_column(:accounts, :school, :string)
    add_column(:accounts, :grad_year, :integer)
  end
end
