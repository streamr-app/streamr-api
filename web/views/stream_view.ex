defmodule Streamr.StreamView do
  use Streamr.Web, :view
  use JaSerializer.PhoenixView
  use Streamr.Sluggifier, attribute: :title

  alias Streamr.{UserView, TopicView, UrlQualifier, UserVoteView, StreamImageSelector}

  attributes [
    :title, :description, :image, :data_url, :audio_data_url, :duration, :published_at,
    :votes_count, :current_user_voted, :image_url
  ]

  has_one :user, serializer: UserView, include: true
  has_one :topic, serializer: TopicView, include: true

  def data_url(stream, _conn) do
    UrlQualifier.cdn_url_for(stream.s3_key)
  end

  def audio_data_url(stream, _conn) do
    UrlQualifier.cdn_url_for(stream.audio_s3_key)
  end

  def image_url(stream, conn) do
    stream.image_s3_keys
    |> StreamImageSelector.select_for(conn.assigns.current_user)
    |> UrlQualifier.cdn_url_for()
  end

  def current_user_voted(stream, conn) do
    UserVoteView.voted?(stream, conn.assigns.current_user)
  end
end
