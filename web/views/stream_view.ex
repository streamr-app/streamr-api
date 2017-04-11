defmodule Streamr.StreamView do
  use Streamr.Web, :view
  use JaSerializer.PhoenixView
  use Streamr.Sluggifier, attribute: :title

  attributes [
    :title, :description, :image, :data_url, :audio_data_url, :duration, :published_at,
    :votes_count, :current_user_voted
  ]

  has_one :user, serializer: Streamr.UserView, include: true
  has_one :topic, serializer: Streamr.TopicView, include: true

  def data_url(stream, _conn) do
    Streamr.UrlQualifier.cdn_url_for(stream.s3_key)
  end

  def audio_data_url(stream, _conn) do
    Streamr.UrlQualifier.cdn_url_for(stream.audio_s3_key)
  end

  def current_user_voted(stream, conn) do
    Streamr.UserVoteView.voted?(stream, conn.assigns.current_user)
  end
end
