defmodule Streamr.Repo.Migrations.AddDurationToStreams do
  use Ecto.Migration

  def change do
    alter table(:streams) do
      add :duration, :integer
    end
  end
end
