defmodule Streamr.StreamView do
  use Streamr.Web, :view
  use JaSerializer.PhoenixView
  use Streamr.Sluggifier, attribute: :title

  attributes [:title, :description, :image]
  has_one :user, serializer: Streamr.UserView, include: true
end
