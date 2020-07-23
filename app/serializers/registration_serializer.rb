class RegistrationSerializer < ActiveModel::Serializer
  attributes :id, :ip_address, :public_name, :public_email, :registered, :joined

  belongs_to :account
end
