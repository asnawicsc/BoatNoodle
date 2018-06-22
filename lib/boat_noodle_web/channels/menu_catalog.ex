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

  def handle_in("open_modal", payload, socket) do
    menu_catalog_id = payload["menu_catalog_id"]
    subcat_id = payload["subcat_id"]

    menu_catalog = Repo.all(from(m in MenuCatalog, where: m.id == ^menu_catalog_id)) |> hd()
    subcat = Repo.all(from(s in ItemSubcat, where: s.subcatid == ^subcat_id)) |> hd()

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

    case subcat.price_code do
      "A" ->
        style = "primary"

      "B" ->
        style = "warning"

      "C" ->
        style = "success"

      "D" ->
        style = "info"

      "E" ->
        style = "rose"

      _ ->
        style = "danger"
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
        Repo.all(from(m in MenuCatalog, where: m.id == ^map["current_catalog_id"])) |> hd()

      item_list = menu_catalog.items
      item_list = String.replace(item_list, map["current_subcat_id"], map["subcat_id"])

      menu_catalog_params = %{
        items: item_list
      }

      case BN.update_menu_catalog(menu_catalog, menu_catalog_params) do
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

  defp authorized?(_payload) do
    true
  end
end
