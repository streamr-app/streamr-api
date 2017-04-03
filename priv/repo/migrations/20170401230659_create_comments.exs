defmodule Streamr.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :stream_id, references(:streams), null: false
      add :user_id, references(:users), null: false
      add :body, :string, null: false

      timestamps()
    end

    create index(:comments, [:stream_id])
    create index(:comments, [:user_id])
  end
end
