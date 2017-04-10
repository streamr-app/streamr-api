defmodule Streamr.CommentView do
  use Streamr.Web, :view
  use JaSerializer.PhoenixView

  attributes [:body, :inserted_at, :votes_count, :current_user_voted]
  has_one :user, serializer: Streamr.UserView, include: true

  def current_user_voted(comment, conn) do
    Streamr.UserVoteView.voted?(comment, conn.assigns.current_user)
  end
end
