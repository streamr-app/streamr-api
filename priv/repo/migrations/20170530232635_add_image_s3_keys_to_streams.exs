defmodule Streamr.Repo.Migrations.AddImageS3KeysToStreams do
  use Ecto.Migration

  def change do
    alter table(:streams) do
      add :image_s3_keys, :map
    end
  end
end
