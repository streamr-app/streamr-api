defmodule Streamr.SVGUploader do
  alias Streamr.{SVGGenerator, S3Service}

  def upload(stream) do
    stream
    |> SVGGenerator.generate()
    |> S3Service.upload_file(stream)
  end
end
