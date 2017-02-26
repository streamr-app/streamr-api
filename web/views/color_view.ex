defmodule Streamr.ColorView do
  use Streamr.Web, :view
  use JaSerializer.PhoenixView

  attributes [:normal, :deuteranopia, :tritanopia, :protanopia, :order]
end
