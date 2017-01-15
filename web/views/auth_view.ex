defmodule Streamr.AuthView do
  def render("unauthenticated.json", _assigns) do
    %{
      errors: [%{
        title: "unauthenticated",
        detail: "Authentication header empty or invalid"
      }]
    }
  end
end
