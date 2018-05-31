defmodule BoatNoodleWeb.CategoryHelper do
  use BoatNoodleWeb, :channel
  require IEx

  def join("menu_item:" <> user_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("update_category_form", %{"map" => map, "cat_id" => cat_id}, socket) do
    item_cat_params =
      map |> Enum.map(fn x -> %{x["name"] => x["value"]} end) |> Enum.flat_map(fn x -> x end)
      |> Enum.into(%{})

    cat = Repo.get(BoatNoodle.BN.ItemCat, cat_id)

    cg = BoatNoodle.BN.ItemCat.changeset(cat, item_cat_params)

    case Repo.update(cg) do
      {:ok, item_cat} ->
        menu_item = Repo.all(BoatNoodle.BN.MenuItem)

        html =
          Phoenix.View.render_to_string(
            BoatNoodleWeb.MenuItemView,
            "category_sidebar.html",
            menu_item: menu_item
          )

        broadcast(socket, "updated_item_cat", %{categories: all_categories(), html: html})

      true ->
        IO.puts("error in inserting item cat")
    end

    {:noreply, socket}
  end

  def handle_in("edit_item_category", %{"cat_id" => cat_id}, socket) do
    cat = Repo.get(BoatNoodle.BN.ItemCat, cat_id)

    broadcast(socket, "open_edit_category", %{
      itemcatcode: cat.itemcatcode,
      itemcatname: cat.itemcatname,
      itemcatdesc: cat.itemcatdesc,
      category_type: cat.category_type,
      itemcatid: cat.itemcatid
    })

    {:noreply, socket}
  end

  def handle_in("delete_item_category", %{"cat_id" => cat_id}, socket) do
    cat = Repo.get(BoatNoodle.BN.ItemCat, cat_id)

    Repo.delete(cat)

    menu_item = Repo.all(BoatNoodle.BN.MenuItem)

    html =
      Phoenix.View.render_to_string(
        BoatNoodleWeb.MenuItemView,
        "category_sidebar.html",
        menu_item: menu_item
      )

    broadcast(socket, "deleted_category", %{html: html})

    {:noreply, socket}
  end

  def handle_in("submit_category_form", %{"map" => map}, socket) do
    item_cat_params =
      map |> Enum.map(fn x -> %{x["name"] => x["value"]} end) |> Enum.flat_map(fn x -> x end)
      |> Enum.into(%{})

    cg = BoatNoodle.BN.ItemCat.changeset(%BoatNoodle.BN.ItemCat{}, item_cat_params)

    case Repo.insert(cg) do
      {:ok, item_cat} ->
        menu_item = Repo.all(BoatNoodle.BN.MenuItem)

        html =
          Phoenix.View.render_to_string(
            BoatNoodleWeb.MenuItemView,
            "category_sidebar.html",
            menu_item: menu_item
          )

        broadcast(socket, "inserted_item_cat", %{html: html})

      true ->
        IO.puts("error in inserting item cat")
    end

    {:noreply, socket}
  end

  defp all_categories() do
    Repo.all(
      from(
        i in BoatNoodle.BN.ItemCat,
        select: %{
          itemcatid: i.itemcatid,
          itemcatname: i.itemcatname,
          itemcatcode: i.itemcatcode,
          itemcatdesc: i.itemcatdesc,
          category_type: i.category_type,
          is_default: i.is_default,
          is_delete: i.is_delete
        }
      )
    )
  end

  def handle_in("load_all_categories", %{"user_id" => user_id}, socket) do
    broadcast(socket, "dt_show_categories", %{categories: all_categories()})
    {:noreply, socket}
  end

  def handle_in("list_items", %{"item_cat_id" => item_cat_id}, socket) do
    items =
      Repo.all(
        from(
          i in BoatNoodle.BN.ItemSubcat,
          where:
            i.itemcatid == ^item_cat_id and i.is_delete == 0 and i.is_combo != 1 and
              i.is_comboitem != 1,
          group_by: [i.itemcode, i.itemname, i.is_activate],
          select: %{
            itemcode: i.itemcode,
            itemname: i.itemname,
            is_activate: i.is_activate
          }
        )
      )

    broadcast(socket, "populate_table_items", %{items: items, item_cat_id: item_cat_id})
    {:noreply, socket}
  end

  defp authorized?(_payload) do
    true
  end
end
