defmodule Streamr.Repo.Migrations.CreateStreams do
  use Ecto.Migration

  def change do
    create table(:streams) do
      add :user_id, references(:users), null: false
      add :title, :string, null: false
      add :description, :string

      timestamps
    end

    create unique_index(:streams, [:user_id])
  end
end
