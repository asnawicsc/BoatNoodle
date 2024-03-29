defmodule BoatNoodleWeb.MenuCatalog do
  use BoatNoodleWeb, :channel
  require IEx

  def join("menu_catalog:" <> user_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("delete_item", payload, socket) do
    map =
      payload["map"]
      |> Enum.map(fn x -> %{x["name"] => x["value"]} end)
      |> Enum.flat_map(fn x -> x end)
      |> Enum.into(%{})

    menu_catalog =
      Repo.all(from m in MenuCatalog, where: m.id == ^map["current_catalog_id"] and m.brand_id==^payload["brand_id"]) |> hd()

    item_list =
      menu_catalog.items
      |> String.split(",")
      |> List.delete(map["current_subcat_id"])
      |> Enum.join(",")

    menu_catalog_params = %{
      items: item_list
    }

     changeset=BoatNoodle.BN.MenuCatalog.changeset(menu_catalog,menu_catalog_params, payload["user_id"],"Update")
    case BoatNoodle.Repo.update(changeset) do
      {:ok, menu_catalog} ->
        broadcast(socket, "deleted_item", %{})
    end
  end

  def handle_in("open_modal", payload, socket) do
    menu_catalog_id = payload["menu_catalog_id"]
    subcat_id = payload["subcat_id"]

    menu_catalog = Repo.all(from m in MenuCatalog, where: m.id == ^menu_catalog_id and m.brand_id==^payload["brand_id"]) |> hd()
    subcat = Repo.all(from s in ItemSubcat, where: s.subcatid == ^subcat_id  and s.brand_id==^payload["brand_id"]) |> hd()

    subcat_price_code_list =
      Repo.all(
        from(
          s in ItemSubcat,
          where:
            s.is_delete == ^0 and s.is_comboitem == ^0 and s.itemcode == ^subcat.itemcode and
              s.brand_id == ^payload["brand_id"],
          select: %{
            subcat_id: s.subcatid,
            price_code: s.price_code,
            itemprice: s.itemprice
          },
          order_by: [asc: s.price_code]
        )
      )

    html =
      Phoenix.View.render_to_string(
        BoatNoodleWeb.MenuCatalogView,
        "catalog_modal.html",
        current_catalog_id: menu_catalog_id,
        current_subcat_id: subcat_id,
        current_price_code: subcat.price_code,
        subcat_lists: subcat_price_code_list,
        conn: socket
      )

    broadcast(socket, "show_modal", %{
      html: html
    })

    {:noreply, socket}
  end

  def handle_in("update_catalog_price", payload, socket) do
    map =
      payload["map"]
      |> Enum.map(fn x -> %{x["name"] => x["value"]} end)
      |> Enum.flat_map(fn x -> x end)
      |> Enum.into(%{})

    subcat = Repo.get_by(ItemSubcat, subcatid: map["subcat_id"], brand_id: payload["brand_id"])

      style = case subcat.price_code do
      "A" ->
      "primary"

      "B" ->
       "warning"

      "C" ->
       "success"

      "D" ->
       "info"

      "E" ->
       "rose"

      _ ->
      "danger"
    end

    if map["current_subcat_id"] == map["subcat_id"] do
      broadcast(socket, "updated_catalog_price", %{
        style: style,
        price:
          :erlang.float_to_binary(
            Decimal.to_float(subcat.itemprice),
            decimals: 2
          ),
        menucat_id: map["current_catalog_id"],
        subcat_id: map["current_subcat_id"],
        new_id: map["subcat_id"]
      })
    else
      menu_catalog =
        Repo.all(from m in MenuCatalog, where: m.id == ^map["current_catalog_id"] and m.brand_id==^payload["brand_id"]) |> hd()

      item_list = menu_catalog.items
      item_list = String.replace(item_list, map["current_subcat_id"], map["subcat_id"])

      menu_catalog_params = %{
        items: item_list
      }

      changeset=BoatNoodle.BN.MenuCatalog.changeset(menu_catalog,menu_catalog_params, payload["user_id"],"Update")
    case BoatNoodle.Repo.update(changeset) do
        {:ok, menu_catalog} ->
          broadcast(socket, "updated_catalog_price", %{
            style: style,
            price: :erlang.float_to_binary(Decimal.to_float(subcat.itemprice), decimals: 2),
            menucat_id: map["current_catalog_id"],
            subcat_id: map["current_subcat_id"],
            new_id: map["subcat_id"]
          })
      end
    end

    {:noreply, socket}
  end

  def handle_in("open_add_modal", payload, socket) do
    menu_catalog_id = payload["menu_catalog_id"]
    item_code = payload["item_code"]

    items = Repo.all(from(i in ItemSubcat, where: i.itemcode == ^item_code))

    html =
      Phoenix.View.render_to_string(
        BoatNoodleWeb.MenuCatalogView,
        "add_item_modal.html",
        menu_catalog_id: menu_catalog_id,
        items: items,
        conn: socket
      )

    broadcast(socket, "show_add_modal", %{
      html: html
    })

    {:noreply, socket}
  end

  def handle_in("update_added_price", payload, socket) do
    map = payload["map"] |> Enum.map(fn x -> {x["name"], x["value"]} end) |> Enum.into(%{})

    menu_catalog =
      Repo.all(from m in MenuCatalog, where: m.id == ^map["menu_catalog_id"] and m.brand_id==^payload["brand_id"]) |> hd()

    items =
      menu_catalog.items
      |> String.split(",")
      |> List.insert_at(0, map["subcatid"])
      |> Enum.join(",")

    menu_catalog_params = %{
      items: items
    }

    changeset=BoatNoodle.BN.MenuCatalog.changeset(menu_catalog,menu_catalog_params, payload["user_id"],"Update")
    case BoatNoodle.Repo.update(changeset) do
      {:ok, menu_catalog} ->
        broadcast(socket, "updated_added_price", %{})
    end
  end

  defp authorized?(_payload) do
    true
  end
end
