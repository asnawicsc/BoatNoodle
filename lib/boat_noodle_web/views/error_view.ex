defmodule BoatNoodleWeb.ErrorView do
  use BoatNoodleWeb, :view

  def render("404.html", _assigns) do
    render("404.html", %{})
  end

  def render("500.html", _assigns) do
    render("500.html", %{})
  end

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
