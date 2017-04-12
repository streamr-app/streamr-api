defmodule Streamr.PreviewUploader do
  alias Streamr.{PreviewGenerator, S3Service}

  def upload(stream, thumbnail_data)  do
    thumbnail_data
    |> PreviewGenerator.generate()
    |> S3Service.upload_file(stream)
  end
end
