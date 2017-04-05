defmodule Streamr.StreamView do
  use Streamr.Web, :view
  use JaSerializer.PhoenixView
  use Streamr.Sluggifier, attribute: :title
  alias Streamr.Stream

  @cdn_url System.get_env("CLOUDFRONT_URL")

  attributes [:title, :description, :image, :data_url, :duration]
  has_one :user, serializer: Streamr.UserView, include: true

  def data_url(%Stream{s3_key: nil}, _conn), do: nil
  def data_url(%Stream{s3_key: s3_key}, _conn) do
    @cdn_url <> s3_key
  end
end
