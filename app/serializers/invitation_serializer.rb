class InvitationSerializer < ActiveModel::Serializer
  attributes :id

  belongs_to :account
end
