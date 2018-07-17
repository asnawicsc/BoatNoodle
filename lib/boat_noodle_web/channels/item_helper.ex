defmodule BoatNoodleWeb.ItemHelper do
  use BoatNoodleWeb, :channel
  require IEx

  def join("item:" <> user_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("submit_item_form", %{"map" => map}, socket) do
  
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
