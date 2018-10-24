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

  def handle_in(
        "update_category_form",
        %{"map" => map, "cat_id" => cat_id, "brand_id" => brand_id, "user_id" => user_id},
        socket
      ) do
    item_cat_params =
      map
      |> Enum.map(fn x -> %{x["name"] => x["value"]} end)
      |> Enum.flat_map(fn x -> x end)
      |> Enum.into(%{})

    cat =
      Repo.all(from(i in ItemCat, where: i.itemcatid == ^cat_id and i.brand_id == ^brand_id))
      |> hd()

    cg = BoatNoodle.BN.ItemCat.changeset(cat, item_cat_params, user_id, "Update")

    case Repo.update(cg) do
      {:ok, item_cat} ->
        menu_item = Repo.all(BoatNoodle.BN.MenuItem)

        html =
          Phoenix.View.render_to_string(
            BoatNoodleWeb.MenuItemView,
            "category_sidebar.html",
            menu_item: menu_item
          )

        broadcast(socket, "updated_item_cat", %{categories: all_categories(brand_id), html: html})

      true ->
        IO.puts("error in inserting item cat")
    end

    {:noreply, socket}
  end

  def handle_in("edit_item_category", %{"cat_id" => cat_id, "brand_id" => brand_id}, socket) do
    cat =
      Repo.all(from(i in ItemCat, where: i.itemcatid == ^cat_id and i.brand_id == ^brand_id))
      |> hd()

    broadcast(socket, "open_edit_category", %{
      itemcatcode: cat.itemcatcode,
      itemcatname: cat.itemcatname,
      itemcatdesc: cat.itemcatdesc,
      category_type: cat.category_type,
      itemcatid: cat.itemcatid
    })

    {:noreply, socket}
  end

  def handle_in("view_item_category", %{"cat_id" => cat_id, "brand_id" => brand_id}, socket) do
    cat =
      Repo.all(from(i in ItemCat, where: i.itemcatid == ^cat_id and i.brand_id == ^brand_id))
      |> hd()

    cat_id = Integer.to_string(cat.itemcatid)

    item_subcat =
      Repo.all(
        from(
          s in ItemSubcat,
          where: s.itemcatid == ^cat_id and s.brand_id == ^brand_id,
          select: %{
            itemcode: s.itemcode,
            itemname: s.itemname,
            price_code: s.price_code,
            is_delete: s.is_delete,
            is_activate: s.is_activate
          }
        )
      )

    html =
      Phoenix.View.render_to_string(
        BoatNoodleWeb.MenuItemView,
        "view_item_category.html",
        itemcatcode: cat.itemcatcode,
        itemcatname: cat.itemcatname,
        itemcatdesc: cat.itemcatdesc,
        category_type: cat.category_type,
        itemcatid: cat.itemcatid,
        item_subcat: item_subcat
      )

    broadcast(socket, "open_view_item_category", %{
      html: html
    })

    {:noreply, socket}
  end

  def handle_in("dis_item_view", %{"cat_id" => cat_id, "brand_id" => brand_id}, socket) do
    cat =
      Repo.all(from(i in BN.Discount, where: i.discountid == ^cat_id and i.brand_id == ^brand_id))
      |> hd()

    discount_item =
      Repo.all(
        from(
          s in BN.DiscountItem,
          where: s.discountid == ^cat.discountid and s.brand_id == ^brand_id,
          select: %{
            discitemsname: s.discitemsname,
            disctype: s.disctype,
            is_visable: s.is_visable,
            is_delete: s.is_delete
          }
        )
      )

    html =
      Phoenix.View.render_to_string(
        BoatNoodleWeb.DiscountView,
        "discount_item_view.html",
        discount_item: discount_item,
        discname: cat.discname
      )

    broadcast(socket, "open_view_discount_item", %{
      html: html
    })

    {:noreply, socket}
  end

  def handle_in(
        "delete_item_category",
        %{"user_id" => user_id, "cat_id" => cat_id, "brand_id" => brand_id, "map" => map},
        socket
      ) do
    cat =
      Repo.all(from(i in ItemCat, where: i.itemcatid == ^cat_id and i.brand_id == ^brand_id))
      |> hd()

    changeset =
      BoatNoodle.BN.ItemCat.changeset(cat, %{is_delete: 1, visable: 0}, user_id, "delete")

    case BoatNoodle.Repo.update(changeset) do
      {:ok, item_cat} ->
        menu_item = Repo.all(BoatNoodle.BN.MenuItem)

        html =
          Phoenix.View.render_to_string(
            BoatNoodleWeb.MenuItemView,
            "category_sidebar.html",
            menu_item: menu_item
          )

        broadcast(socket, "deleted_category", %{html: html})

      true ->
        IO.puts("error in inserting item cat")
    end

    {:noreply, socket}
  end

  def handle_in(
        "submit_category_form",
        %{"map" => map, "brand_id" => brand_id, "user_id" => user_id},
        socket
      ) do
    item_cat_params =
      map
      |> Enum.map(fn x -> %{x["name"] => x["value"]} end)
      |> Enum.flat_map(fn x -> x end)
      |> Enum.into(%{})

    item_cat_params = Map.put(item_cat_params, "brand_id", brand_id)

    cg =
      BoatNoodle.BN.ItemCat.changeset(
        %BoatNoodle.BN.ItemCat{},
        item_cat_params,
        user_id,
        "Create"
      )

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

  defp all_categories(brand_id) do
    Repo.all(
      from(
        i in BoatNoodle.BN.ItemCat,
        where: i.brand_id == ^brand_id and i.visable == ^1 and i.is_delete == ^0,
        select: %{
          itemcatid: i.itemcatid,
          itemcatname: i.itemcatname,
          itemcatcode: i.itemcatcode,
          itemcatdesc: i.itemcatdesc,
          category_type: i.category_type,
          is_default: i.is_default,
          is_delete: i.is_delete,
          sort_no: i.sort_no
        }
      )
    )
  end

  def handle_in("load_all_categories", %{"user_id" => user_id, "brand_id" => brand_id}, socket) do
    broadcast(socket, "dt_show_categories", %{categories: all_categories(brand_id)})
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

  def handle_in("assign_to_unused", payload, socket) do
    item =
      Repo.get_by(
        BoatNoodle.BN.ItemSubcat,
        subcatid: payload["subcat_id"],
        brand_id: payload["brand_id"]
      )

    edit_item =
      BoatNoodle.BN.ItemSubcat.changeset(
        item,
        %{is_delete: 1},
        payload["user"],
        "Update ItemSubcat"
      )
      |> Repo.update()

    action = "This item is successfully deactivate"

    broadcast(socket, "populate_assign_to_unused", %{action: action})
    {:noreply, socket}
  end

  defp authorized?(_payload) do
    true
  end
end
