class MenteeSerializer < ActiveModel::Serializer
  attributes :id, :classroom

  has_one :account
end
