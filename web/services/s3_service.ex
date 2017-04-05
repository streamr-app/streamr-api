defmodule Streamr.S3Service do
  alias ExAws.S3

  @bucket_name System.get_env("AWS_S3_BUCKET_NAME")

  def upload_file(local_path, model) do
    resource_path = resource_path_for(model, local_path)

    local_path
    |> S3.Upload.stream_file
    |> S3.upload(@bucket_name, resource_path)
    |> ExAws.request!

    resource_path
  end

  defp resource_path_for(model, filepath) do
    "#{table_name(model)}/#{model.id}/#{hashed_contents(filepath)}"
  end

  defp hashed_contents(filepath) do
    filepath
    |> File.stream!()
    |> Enum.reduce(:crypto.hash_init(:sha256), fn(line, acc) -> :crypto.hash_update(acc,line) end)
    |> :crypto.hash_final
    |> Base.encode16
  end

  defp table_name(model) do
    model.__struct__.__schema__(:source)
  end
end
