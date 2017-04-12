defmodule Streamr.Repo.Migrations.RenameImageToImageS3Key do
  use Ecto.Migration

  def change do
    rename table(:streams), :image, to: :image_s3_key
  end
end
