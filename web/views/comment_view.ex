defmodule Streamr.CommentView do
  use Streamr.Web, :view
  use JaSerializer.PhoenixView

  attributes [:body]
  has_one :user, serializer: Streamr.UserView, include: true
end
