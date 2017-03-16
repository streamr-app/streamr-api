defmodule Streamr.Repo.Migrations.AddS3PathToStreams do
  use Ecto.Migration

  def change do
    alter table(:streams) do
      add :s3_path, :string
    end
  end
end
