defmodule Streamr.Repo.Migrations.AddImageS3KeyToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :image_s3_key, :string
    end
  end
end
