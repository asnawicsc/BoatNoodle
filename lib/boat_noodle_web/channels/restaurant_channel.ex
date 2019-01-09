defmodule BoatNoodleWeb.RestaurantChannel do
  use BoatNoodleWeb, :channel

  def join("restaurant:" <> branchcode, payload, socket) do
    if authorized?(payload, branchcode) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("order_completed", payload, socket) do
    # broadcast(socket, "shout", payload)
    IO.inspect(payload)
    branchcode = socket.topic |> String.split(":") |> List.last()
    branch = Repo.all(from(b in Branch, where: b.branchcode == ^branchcode)) |> List.first()

    brand_id = branch.brand_id
    sales_param = payload["sales"]["sales"]
    sales_param = Map.put(sales_param, "brand_id", brand_id)
    sales_param = Map.put(sales_param, "branchid", Integer.to_string(branch.branchid))
    a = Sales.changeset(%Sales{}, sales_param) |> Repo.insert()
    IO.inspect(a)

    for map <- payload["sales"]["sales_details"] do
      sales_detail_param = map
      sales_detail_param = Map.put(sales_detail_param, "brand_id", brand_id)
      b = SalesMaster.changeset(%SalesMaster{}, sales_detail_param) |> Repo.insert()
      IO.inspect(b)
    end

    for map <- payload["sales"]["sales_payment"] do
      sales_payment_param = map
      sales_payment_param = Map.put(sales_payment_param, "brand_id", brand_id)

      c =
        SalesPayment.changeset(%SalesPayment{}, sales_payment_param)
        |> Repo.insert()

      IO.inspect(c)
    end

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
          left_join: c in ItemCat,
          on: c.itemcatid == i.itemcatid,
          where: i.brand_id == ^branch.brand_id and i.subcatid in ^ids,
          select: %{
            name: i.itemname,
            price: i.itemprice,
            printer_ip: "10.239.30.114",
            port_no: 9100,
            category: c.itemcatname,
            img_url: ""
          }
        )
      )

    broadcast(socket, "new_menu_items", %{menu_items: items})
    {:noreply, socket}
  end

  # EcomBackendWeb.Endpoint.broadcast(topic, event, message)
  # Add authorization logic here as required.
  defp authorized?(payload, branchcode) do
    IO.inspect(payload)
    branches = Repo.all(from(b in Branch, where: b.branchcode == ^branchcode))

    branch =
      if branches != [] do
        branches |> List.first()
      else
        %{api_key: nil}
      end

    payload["license_key"] == branch.api_key
  end
end
