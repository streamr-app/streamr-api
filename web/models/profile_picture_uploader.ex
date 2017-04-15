defmodule Streamr.ProfilePictureUploader do
  alias Streamr.S3Service

  @size "%[fx: w>h ? h : w]"
  @offset_x "%[fx: w>h ? (w-h)/2 : 0]"
  @offset_y "%[fx: w>h ? 0 : (h-w)/2]"
  @viewport "#{@size}x#{@size}+#{@offset_x}+#{@offset_y}"

  def upload(base64_image, user) do
    base64_image
    |> generate_image(filepath_for(user))
    |> S3Service.upload_file(user)
  end

  defp generate_image(base64_image, filepath) do
    File.write!(filepath, base64_image)

    System.cmd("convert", [
      "inline:#{filepath}",
      "-set", "option:distort:viewport", @viewport,
      "-filter", "point",
      "-distort", "SRT",
      "0", "+repage",
      "#{filepath}.jpg"
    ])

    "#{filepath}.jpg"
  end

  defp filepath_for(user) do
    "uploads/user_profile_picture_#{user.id}"
  end
end
