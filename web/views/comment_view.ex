defmodule Streamr.CommentView do
  use Streamr.Web, :view
  use JaSerializer.PhoenixView

  attributes [:body, :inserted_at, :votes_count]
  has_one :user, serializer: Streamr.UserView, include: true
end
