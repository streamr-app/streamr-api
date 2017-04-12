defmodule Streamr.InitialCreator do
  alias Streamr.{S3Service, User, Repo}

  def process(user) do
    filepath = filepath_for(user)

    filepath
    |> generate_image(user)
    |> S3Service.upload_file(user)
    |> User.image_key_changeset(user)
    |> Repo.update()
  end

  defp generate_image(filepath, user) do
    System.cmd("convert", params_for(user, filepath))

    filepath
  end

  defp params_for(user, filepath) do
    initials = user.name |> String.split(" ") |> format_initials()
    background_color = generate_background_color(user)

    [
        "-density", "216",
        "-size", "1536x1536",
        "canvas:##{background_color}",
        "-fill", text_color(background_color),
        "-pointsize", "200",
        "-gravity", "center",
        "-annotate", "+0+25", initials,
        "-resample", "72",
        filepath
    ]
  end

  defp generate_background_color(user) do
    :sha256
    |> :crypto.hash(user.name <> user.email)
    |> Base.encode16()
    |> String.slice(0..5)
  end

  defp text_color(background_color) do
    luminance = background_color |> extract_rgb() |> calculate_luminance()

    if luminance > 125, do: "#000000", else: "#ffffff"
  end

  defp calculate_luminance([red, green, blue]) do
    (red * 299 + green * 587 + blue * 114) / 1000
  end

  defp extract_rgb(hex) do
    hex
    |> String.graphemes()
    |> Enum.chunk(2)
    |> Enum.map(fn(chunk) -> String.to_integer(Enum.join(chunk), 16) end)
  end

  defp format_initials(names) do
    names
    |> limit_names()
    |> Enum.reduce("", fn(name, initials) -> initials <> String.first(name) end)
  end

  defp filepath_for(user), do: "uploads/user_initials_#{user.id}.png"

  defp limit_names([first_name]), do: [first_name]
  defp limit_names([first_name | other_names]), do: [first_name, List.last(other_names)]
end
