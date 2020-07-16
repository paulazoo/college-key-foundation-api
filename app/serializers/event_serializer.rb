class EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :link, :kind, :start_time, :end_time, :image_url

  has_many :invitations
end
