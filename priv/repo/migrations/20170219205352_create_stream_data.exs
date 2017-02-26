defmodule Streamr.Repo.Migrations.CreateStreamData do
  use Ecto.Migration

  def change do
    create table(:stream_data) do
      add :stream_id, references(:streams), null: false
      add :lines, {:array, :json}

      timestamps
    end
  end
end
