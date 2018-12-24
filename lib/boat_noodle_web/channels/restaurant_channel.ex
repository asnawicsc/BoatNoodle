defmodule BoatNoodleWeb.RestaurantChannel do
  use BoatNoodleWeb, :channel

  def join("restaurant:" <> branchcode, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("order_completed", payload, socket) do
    # broadcast(socket, "shout", payload)
    IO.inspect(payload)
    a = Sales.changeset(%Sales{}, payload) |> Repo.insert()

    IO.inspect(a)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
