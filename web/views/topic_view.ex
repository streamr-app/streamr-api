defmodule Streamr.TopicView do
  use Streamr.Web, :view
  use JaSerializer.PhoenixView
  use Streamr.Sluggifier, :name

  attributes [:name]
end
