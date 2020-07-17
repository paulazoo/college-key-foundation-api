class AccountSerializer < ActiveModel::Serializer
  attributes :id, :name, :given_name, :family_name, :email, :google_id, :image_url, :display_name, :bio, :phone, :school, :grad_year, :user_id, :user_type

end
