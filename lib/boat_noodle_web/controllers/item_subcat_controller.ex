defmodule BoatNoodleWeb.ItemSubcatController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.{MenuItem, ItemSubcat, ComboDetails}
  require IEx

  def combo_create(conn, params) do

    ala_cart_ids = params["item"]["itemcode"] |> String.split(",")
    itemname = params["itemcode"]<>" "<>params["itemdesc"]
    params = Map.put(params, "itemname", itemname)
    prev_subcatid = Repo.all(from c in ItemSubcat, 
      select: %{subcatid: c.subcatid}) 
    |> Enum.map(fn x -> Integer.to_string(x.subcatid) end) 
    |> Enum.filter(fn x -> String.length(x) == 6 end) 
    |> Enum.sort() 
    |> List.last

    subcatid = String.to_integer(prev_subcatid) + 1
    params = Map.put(params, "subcatid", subcatid)
    cg = ItemSubcat.changeset(%ItemSubcat{}, params)

    case Repo.insert(cg) do
      {:ok, cg} ->
      comboitems = Repo.all(from s in ItemSubcat, where: s.itemcode in ^ala_cart_ids, group_by: [s.itemcode],select: %{itemcode: s.itemcode, itemname: s.itemname, itemprice: s.itemprice, subcatid: s.subcatid, pricecode: s.price_code, itemdesc: s.itemdesc})
      for comboitem <- comboitems do
        sci = Integer.to_string(subcatid)<>Integer.to_string(comboitem.subcatid)
        comboitem = Map.put(comboitem, :subcatid, String.to_integer(sci))
        comboitem = Map.put(comboitem, :is_comboitem, 1)
        comboitem = Map.put(comboitem, :itemcatid, Integer.to_string(subcatid))
        comboitem = Map.delete(comboitem, :itemprice)
        cg2 = ItemSubcat.changeset(%ItemSubcat{}, comboitem)
 
        Repo.insert(cg2)
      end
      conn
      |> put_flash(:info, "combo created")
      |> redirect(to: menu_item_path(conn, :index))

      _ ->
      conn
      |> put_flash(:error, "combo not created")
      |> redirect(to: menu_item_path(conn, :index))
        
    end
  end

  def combo_new(conn, _params) do
    menu_item = Repo.all(from i in MenuItem, where: i.category_type == ^"COMBO")

    ala_carte = Repo.all(from s in ItemSubcat, left_join: i in MenuItem, on: i.itemcatid == s.itemcatid, where: i.category_type != ^"COMBO", group_by: [s.itemcode], select: %{
      subcatid: s.subcatid,
      itemname: s.itemname,
      itemdesc: s.itemdesc,
      itemcode: s.itemcode
      }, order_by: [asc: s.itemcode])
# IEx.pry
    render(
      conn,
      "combo_new.html",
      menu_item: menu_item,ala_carte: ala_carte
    )
  end

  def combo_show(conn, %{"subcatid" => id}) do
    item_subcat = BN.get_item_subcat!(id)
    # IEx.pry()

    same_items =
      Repo.all(
        from(
          s in ItemSubcat,
          where: s.itemcode == ^item_subcat.itemcode and s.is_delete == ^0,
          order_by: [asc: s.price_code]
        )
      )
      if same_items == [] do
        same_items = [item_subcat]
      end

    ids = same_items |> Enum.map(fn x -> x.subcatid end)
    combo_items = Repo.all(from(c in ComboDetails, where: c.combo_id in ^ids))

    no_selection_combo_items = Repo.all(from s in ItemSubcat, where: s.itemcatid == ^Integer.to_string(item_subcat.subcatid))

    render(
      conn,
      "combo_show.html",
      item_subcat: item_subcat,
      same_items: same_items,
      combo_items: combo_items,
      no_selection_combo_items: no_selection_combo_items
    )
  end

  def item_show(conn, %{"subcatid" => id}) do
    item_subcat = BN.get_item_subcat!(id)
    # IEx.pry()

    same_items =
      Repo.all(
        from(
          s in ItemSubcat,
          where:
            s.itemcode == ^item_subcat.itemcode and s.is_combo == ^0 and s.is_comboitem == ^0 and
              s.is_delete == ^0,
          order_by: [asc: s.price_code]
        )
      )

    render(conn, "show.html", item_subcat: item_subcat, same_items: same_items)
  end

  def index(conn, _params) do
    item_subcat = BN.list_item_subcat()
    render(conn, "index.html", item_subcat: item_subcat)
  end

  def new(conn, _params) do
    changeset = BN.change_item_subcat(%ItemSubcat{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"item_subcat" => item_subcat_params}) do
    case BN.create_item_subcat(item_subcat_params) do
      {:ok, item_subcat} ->
        conn
        |> put_flash(:info, "Item subcat created successfully.")
        |> redirect(to: item_subcat_path(conn, :show, item_subcat))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    item_subcat = BN.get_item_subcat!(id)
    render(conn, "show.html", item_subcat: item_subcat)
  end

  def edit(conn, %{"id" => id}) do
    item_subcat = BN.get_item_subcat!(id)
    changeset = BN.change_item_subcat(item_subcat)
    render(conn, "edit.html", item_subcat: item_subcat, changeset: changeset)
  end

  def update(conn, %{"id" => id, "item_subcat" => item_subcat_params}) do
    item_subcat = BN.get_item_subcat!(id)

    case BN.update_item_subcat(item_subcat, item_subcat_params) do
      {:ok, item_subcat} ->
        conn
        |> put_flash(:info, "Item subcat updated successfully.")
        |> redirect(to: item_subcat_path(conn, :show, item_subcat))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", item_subcat: item_subcat, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    item_subcat = BN.get_item_subcat!(id)
    {:ok, _item_subcat} = BN.delete_item_subcat(item_subcat)

    conn
    |> put_flash(:info, "Item subcat deleted successfully.")
    |> redirect(to: item_subcat_path(conn, :index))
  end
end
