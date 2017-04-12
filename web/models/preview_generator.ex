defmodule Streamr.PreviewGenerator do
  def generate("data:image/svg+xml;base64," <> data) do
    filepath = "uploads/#{filename(data)}.svg"

    decoded_svg = decode(data)
    File.write(filepath, decoded_svg)
    convert_to_png(filepath)
  end

  def convert_to_png(filepath) do
    new_filepath = String.replace_trailing(filepath, ".svg", ".png")

    System.cmd("convert", [filepath, new_filepath])

    new_filepath
  end

  def decode(data) do
    data
    |> String.trim()
    |> String.trim_trailing("=")
    |> Base.decode64!(padding: false)
  end

  def filename(data) do
    :sha256
    |> :crypto.hash(data)
    |> Base.encode16
  end
end
