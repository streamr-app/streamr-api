defmodule Streamr.Repo.Migrations.AddAudioS3KeyToStreams do
  use Ecto.Migration

  def change do
    alter table(:streams) do
      add :audio_s3_key, :string
    end
  end
end
