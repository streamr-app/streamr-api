defmodule Streamr.Repo.Migrations.RemoveStreamIndex do
  use Ecto.Migration

  def change do
    drop unique_index(:streams, [:user_id])
    create index(:streams, [:user_id])
  end
end
