defmodule Streamr.Vote do
  use Streamr.Web, :model
  import Ecto.Query

  alias Streamr.{User, Comment, Stream, Repo, Vote}

  schema "votes" do
    belongs_to :user, User
    belongs_to :comment, Comment
    belongs_to :stream, Stream

    timestamps()
  end

  def count(%Stream{id: id}) do
    count_associations(from v in Vote, where: v.stream_id == ^id)
  end

  def count(%Comment{id: id}) do
    count_associations(from v in Vote, where: v.comment_id == ^id)
  end

  def changeset(vote, params \\ %{}) do
    vote
    |> cast(params, [:comment_id, :stream_id])
    |> unique_constraint(:comment_id, name: :index_votes_on_comment)
    |> unique_constraint(:stream_id, name: :index_votes_on_stream)
  end

  defp count_associations(query) do
    Repo.aggregate(query, :count, :id)
  end
end
