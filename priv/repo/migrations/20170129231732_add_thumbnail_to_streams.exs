defmodule Streamr.Repo.Migrations.AddThumbnailToStreams do
  use Ecto.Migration

  def change do
    alter table(:streams) do
      add :image, :string
    end
  end
end
