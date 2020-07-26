class EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :link, :kind, :start_time, :end_time, :image_url, :host, :public_link

  has_many :invitations
end
