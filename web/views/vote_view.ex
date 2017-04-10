defmodule Streamr.VoteView do
  use Streamr.Web, :view
  use JaSerializer.PhoenixView

  def render("missing_vote.json", _assigns) do
    %{errors: [
      %{
        title: "missing_vote",
        detail: "User has not voted on this resource",
        status: 422
      }
    ]}
  end
end
