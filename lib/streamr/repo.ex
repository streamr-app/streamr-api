defmodule Streamr.Repo do
  use Ecto.Repo, otp_app: :streamr
  use Scrivener, page_size: 20

  def get_by_slug(model, id_or_slug) do
    {id, _} = Integer.parse(id_or_slug)
    get(model, id)
  end
end
