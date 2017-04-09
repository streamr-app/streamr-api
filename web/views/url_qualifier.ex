defmodule Streamr.UrlQualifier do
  @cdn_url System.get_env("CLOUDFRONT_URL")

  def cdn_url_for(nil), do: nil
  def cdn_url_for(s3_key), do: @cdn_url <> s3_key
end
