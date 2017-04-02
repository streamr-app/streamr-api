defmodule Streamr.Repo.Migrations.ChangeS3PathToDataUrl do
  use Ecto.Migration

  def change do
    rename table(:streams), :s3_path, to: :data_url
  end
end
