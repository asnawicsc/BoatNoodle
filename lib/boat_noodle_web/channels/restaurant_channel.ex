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

  def handle_in("get_menu_items", payload, socket) do
    branchcode = String.split(socket.topic, ":") |> List.last()
    branch = Repo.all(from(b in Branch, where: b.branchcode == ^branchcode)) |> List.first()

    menu_catalog =
      Repo.all(from(m in MenuCatalog, where: m.id == ^branch.menu_catalog)) |> List.first()

    ids = menu_catalog.items |> String.split(",")

    items =
      Repo.all(
        from(
          i in ItemSubcat,
          where: i.brand_id == ^branch.brand_id and i.subcatid in ^ids,
          select: %{
            name: i.itemname,
            price: i.itemprice,
            printer_ip: "10.239.30.114",
            port_no: 9100
          }
        )
      )

    broadcast(socket, "new_menu_items", %{menu_items: items})
    {:noreply, socket}
  end

  # EcomBackendWeb.Endpoint.broadcast(topic, event, message)
  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
