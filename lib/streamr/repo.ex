defmodule Streamr.Repo do
  use Ecto.Repo, otp_app: :streamr
  use Scrivener, page_size: 20
end
