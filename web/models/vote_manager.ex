defmodule Streamr.VoteManager do
  alias Ecto.Multi
  alias Streamr.{Vote, Comment, Stream, Repo}

  def create(user, params) do
    Multi.new
    |> Multi.insert(:vote, vote_changeset(user, params))
    |> Multi.update(:voteable, vote_quantity_changeset(params, :increment))
    |> Repo.transaction()
  end

  def delete(vote) do
    Multi.new
    |> Multi.delete(:vote, vote)
    |> Multi.update(:voteable, vote_quantity_changeset(vote, :decrement))
    |> Repo.transaction()
  end

  defp vote_changeset(user, params) do
    user |> Ecto.build_assoc(:votes) |> Vote.changeset(params)
  end

  defp vote_quantity_changeset(%{"comment_id" => comment_id}, increment_or_decrement) do
    Comment
    |> Repo.get!(comment_id)
    |> Comment.change_votes_count_changeset(increment_or_decrement)
  end

  defp vote_quantity_changeset(%{"stream_id" => stream_id}, increment_or_decrement) do
    Stream
    |> Repo.get!(stream_id)
    |> Stream.change_votes_count_changeset(increment_or_decrement)
  end

  defp vote_quantity_changeset(%Vote{stream: stream, comment: nil}, increment_or_decrement) do
    Stream.change_votes_count_changeset(stream, increment_or_decrement)
  end

  defp vote_quantity_changeset(%Vote{comment: comment, stream: nil}, increment_or_decrement) do
    Comment.change_votes_count_changeset(comment, increment_or_decrement)
  end
end
