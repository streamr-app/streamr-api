defmodule Streamr.Repo.Migrations.StoreS3KeyInsteadOfFullDataUrl do
  use Ecto.Migration

  def up do
    rename table(:streams), :data_url, to: :s3_key
    cloudfront_url = System.get_env("CLOUDFRONT_URL")

    execute "update streams set s3_key = replace(s3_key, '#{cloudfront_url}', '')"
  end

  def down do
    rename table(:streams), :s3_key, to: :data_url
    cloudfront_url = System.get_env("CLOUDFRONT_URL")

    execute "update streams set data_url = '#{cloudfront_url}' || data_url"
  end
end
