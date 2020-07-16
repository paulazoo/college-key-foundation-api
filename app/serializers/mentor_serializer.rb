class MentorSerializer < ActiveModel::Serializer
  attributes :id

  has_one :account
end
