defmodule Streamr.StreamView do
  use Streamr.Web, :view
  use JaSerializer.PhoenixView

  attributes [:title, :description]
  has_one :user, serializer: Streamr.UserView, include: true
end
