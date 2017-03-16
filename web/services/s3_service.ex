defmodule Streamr.S3Service do
  alias ExAws.S3

  @bucket_name System.get_env("AWS_S3_BUCKET_NAME")
  @region System.get_env("AWS_S3_REGION")
  @base_url "https://s3-#{@region}.amazonaws.com/#{@bucket_name}/"

  def upload_file(local_path, model) do
    s3_path = s3_path_for(model, local_path)

    local_path
    |> S3.Upload.stream_file
    |> S3.upload(@bucket_name, s3_path)
    |> ExAws.request!

    link_to(s3_path)
  end

  defp link_to(s3_path) do
    @base_url <> s3_path
  end

  defp s3_path_for(model, filepath) do
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
