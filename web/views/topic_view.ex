defmodule Streamr.TopicView do
  use Streamr.Web, :view
  use JaSerializer.PhoenixView
  use Streamr.Sluggifier, attribute: :name

  attributes [:name]
end
