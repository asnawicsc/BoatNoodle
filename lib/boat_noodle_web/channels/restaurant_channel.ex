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
          left_join: r in BoatNoodle.BN.SubcatCatalog,
          on: r.subcat_id == i.subcat_id,
          left_join: t in BoatNoodle.BN.ItemCat,
          on: t.id == i.menu_cat_id,
          where:
            t.brand_id == ^menu_catalog.brand_id and i.brand_id == ^menu_catalog.brand_id and
              r.brand_id == ^menu_catalog.brand_id and r.catalog_id == ^menu_catalog.id and
              r.is_active == ^1 and r.is_combo != ^1,
          select: %{
            name: i.itemname,
            price: r.price,
            category_name: t.itemcatname,
            printer_ip: "10.239.30.114",
            port_no: 9100
          }
        )
      )

    broadcast(socket, "new_menu_items", %{menu_items: items})
    {:noreply, socket}
  end

  def handle_in("get_combo_items", payload, socket) do
    branchcode = String.split(socket.topic, ":") |> List.last()
    branch = Repo.all(from(b in Branch, where: b.branchcode == ^branchcode)) |> List.first()

    menu_catalog =
      Repo.all(from(m in MenuCatalog, where: m.id == ^branch.menu_catalog)) |> List.first()

    combo_items_header =
      Repo.all(
        from(
          i in BoatNoodle.BN.ItemSubcat,
          left_join: r in BoatNoodle.BN.SubcatCatalog,
          on: r.subcat_id == i.subcat_id,
          where:
            i.brand_id == ^menu_catalog.brand_id and r.brand_id == ^menu_catalog.brand_id and
              r.catalog_id == ^menu_catalog.id and r.is_active == ^1 and r.is_combo == ^1,
          select: %{
            name: i.itemname,
            price: r.price,
            start_date: r.start_date,
            end_date: r.end_date,
            printer_ip: "10.239.30.114",
            port_no: 9100
          }
        )
      )

    sub_combo_item =
      Repo.all(
        from(
          i in BoatNoodle.BN.ComboDetails,
          left_join: r in BoatNoodle.BN.ComboCatalog,
          on: r.id == i.combo_item_id,
          left_join: t in BoatNoodle.BN.ItemCat,
          on: t.id == i.menu_cat_id,
          where:
            i.brand_id == ^menu_catalog.brand_id and t.brand_id == ^menu_catalog.brand_id and
              r.brand_id == ^menu_catalog.brand_id and r.catalog_id == ^menu_catalog.id and
              r.is_active == ^1 and r.is_combo == 1,
          select: %{
            name: i.combo_item_name,
            price: r.price,
            to_up: r.to_up,
            category_limit: i.combo_qty,
            category_name: t.itemcatname,
            printer_ip: "10.239.30.114",
            port_no: 9100
          }
        )
      )

    broadcast(socket, "new_menu_items", %{
      combo_items_header: combo_items_header,
      sub_combo_item: sub_combo_item
    })

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
