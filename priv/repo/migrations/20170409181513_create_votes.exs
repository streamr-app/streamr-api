defmodule Streamr.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :user_id, references(:users), null: false
      add :stream_id, references(:streams)
      add :comment_id, references(:comments)

      timestamps()
    end

    create unique_index(:votes, [:user_id, :comment_id], name: :index_votes_on_comment)
    create unique_index(:votes, [:user_id, :stream_id], name: :index_votes_on_stream)
  end
end
