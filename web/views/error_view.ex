defmodule Streamr.ErrorView do
  use Streamr.Web, :view

  def render("403.json", _assigns) do
    %{errors: [%{
        title: "unauthorized",
        detail: "you are not authorized to perform that action"}]}
  end

  def render("404.html", _assigns) do
    "Page not found"
  end

  def render("404.json", assigns) do
    error_detail = assigns |> Map.get(:reason) |> Map.get(:message)

    %{errors: [%{
        title: "record not found",
        detail: error_detail}]}
  end

  def render("500.html", _assigns) do
    "Internal server error"
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end
end
