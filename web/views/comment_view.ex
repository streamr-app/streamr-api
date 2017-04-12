defmodule Streamr.CommentView do
  use Streamr.Web, :view
  use JaSerializer.PhoenixView

  alias Streamr.{UserView, UserVoteView}

  attributes [:body, :inserted_at, :votes_count, :current_user_voted]
  has_one :user, serializer: UserView, include: true

  def current_user_voted(comment, conn) do
    UserVoteView.voted?(comment, conn.assigns.current_user)
  end
end
