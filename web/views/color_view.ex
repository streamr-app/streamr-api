defmodule Streamr.ColorView do
  use Streamr.Web, :view
  use JaSerializer.PhoenixView

  attributes [:hex, :normal, :deuteranopia, :tritanopia, :protanopia]

  def hex(color, %{assigns: %{current_user: nil}}), do: color.normal
  def hex(color, %{assigns: %{current_user: user}}), do: Map.get(color, user.color_preference)
end
