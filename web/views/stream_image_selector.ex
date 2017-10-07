defmodule Streamr.StreamImageSelector do
  alias Streamr.User

  def select_for(nil, _user), do: nil

  def select_for(image_s3_keys, nil) do
    Map.get(image_s3_keys, "normal")
  end

  def select_for(image_s3_keys, %User{color_preference: color_preference}) do
    Map.get(image_s3_keys, Atom.to_string(color_preference))
  end
end
