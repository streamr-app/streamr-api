defmodule Streamr.Repo.Migrations.AddPublishedAtToStreams do
  use Ecto.Migration

  def up do
    alter table(:streams) do
      add :published_at, :utc_datetime
    end

    execute "update streams set published_at = inserted_at + interval '1 second' * duration"
  end

  def down do
    alter table(:streams) do
      remove :published_at
    end
  end
end
