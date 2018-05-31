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
    item_subcat_params =
      map |> Enum.map(fn x -> %{x["name"] => x["value"]} end) |> Enum.flat_map(fn x -> x end)
      |> Enum.into(%{})

    cat_id = item_subcat_params["itemcatid"]
    cat = Repo.get(BoatNoodle.BN.ItemCat, cat_id)
    itemcode = item_subcat_params["itemcode"]
    first_letter = itemcode |> String.split("") |> Enum.reject(fn x -> x == "" end) |> hd()

    if Float.parse(first_letter) == :error do
      running_no = itemcode |> String.split("") |> Enum.reject(fn x -> x == "" end) |> tl()

      if Enum.count(running_no) == 2 do
        part_code =
          List.insert_at(running_no, 0, "0") |> List.insert_at(0, first_letter) |> Enum.join()

        itemname = itemcode <> " " <> item_subcat_params["itemdesc"]
        extension_params = %{"itemname" => itemname, "part_code" => part_code}
        item_param = Map.merge(item_subcat_params, extension_params)
        cg = BoatNoodle.BN.ItemSubcat.changeset(%BoatNoodle.BN.ItemSubcat{}, item_param)

        case Repo.insert(cg) do
          {:ok, item_cat} ->
            broadcast(socket, "inserted_item_subcat", %{})

          true ->
            IO.puts("error in inserting item subcat")
        end
      else
        IO.puts("code behind are not numbers")
      end
    else
      IO.puts("code first letter is not alphabet")
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
