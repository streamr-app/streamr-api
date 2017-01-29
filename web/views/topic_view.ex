defmodule Streamr.TopicView do
  use Streamr.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name]
end
