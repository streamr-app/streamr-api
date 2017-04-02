defmodule Streamr.S3Service do
  alias ExAws.S3

  @bucket_name System.get_env("AWS_S3_BUCKET_NAME")
  @cloudfront_url System.get_env("CLOUDFRONT_URL")

  def upload_file(local_path, model) do
    resource_path = resource_path_for(model, local_path)

    local_path
    |> S3.Upload.stream_file
    |> S3.upload(@bucket_name, resource_path)
    |> ExAws.request!

    link_to(resource_path)
  end

  defp link_to(resource_path) do
    @cloudfront_url <> resource_path
  end

  defp resource_path_for(model, filepath) do
    "#{table_name(model)}/#{model.id}/#{hashed_path(filepath)}"
  end

  defp hashed_path(filepath) do
    :sha256
    |> :crypto.hash(filepath)
    |> Base.encode16
  end

  defp table_name(model) do
    model.__struct__.__schema__(:source)
  end
end
