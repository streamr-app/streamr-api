defmodule Streamr.UserVoteView do
  def voted?(_stream_or_comment, nil), do: false
  def voted?(%{votes: votes}, user) do
    Enum.any?(votes, fn(vote) -> vote.user_id == user.id end)
  end
end
