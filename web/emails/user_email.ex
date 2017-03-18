defmodule Streamr.Email do
  use Phoenix.Swoosh, view: Streamr.Email.UserView, layout: {Streamr.LayoutView, :email}
  # When we want to do HTML
  # use view: Streamr.EmailView

  def welcome(user) do
    new()
    |> to({user.name, user.email})
    |> from({"Team Streamr", "team@streamr.live"})
    |> subject("Welcome to Streamr")
    |> render_body("welcome.html" , %{name: user.name})
  end
end
