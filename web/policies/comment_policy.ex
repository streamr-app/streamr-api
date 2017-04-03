defmodule Streamr.Comment.Policy do
  def can?(user, :delete, comment) do
    user.id == comment.user_id
  end
end
