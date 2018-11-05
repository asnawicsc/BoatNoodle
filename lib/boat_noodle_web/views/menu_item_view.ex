defmodule BoatNoodleWeb.MenuItemView do
  use BoatNoodleWeb, :view
  alias BoatNoodle.Repo
  alias BoatNoodle.BN.{ItemCat, Brand, ItemSubcat}

  import Ecto.Query
  require IEx

  def item_subcats(ids) do
    ids =
      String.split(ids, ",")
      |> Enum.reject(fn x -> x == "" end)
      |> Enum.map(fn x -> String.to_integer(x) end)

    Repo.all(
      from(
        i in ItemSubcat,
        left_join: c in ItemCat,
        on: c.itemcatid == i.itemcatid,
        where: i.subcatid in ^ids,
        select: %{
          itemcatid: i.itemcatid,
          catname: c.itemcatname,
          itemname: i.itemname,
          itemprice: i.itemprice,
          subcatid: i.subcatid
        }
      )
    )

    # |> Enum.group_by(fn x -> x.itemcatid end)
  end

  def subcat_data(conn) do
    subcats =
      Repo.all(from(i in ItemSubcat, where: i.brand_id == ^conn.private.plug_session["brand_id"]))
  end

  def pricing(subcatid, brand, subcat_data) do
    subcat = subcat_data |> Enum.filter(fn x -> x.subcatid == subcatid end) |> hd()

    same_items =
      subcat_data
      |> Enum.filter(fn x -> x.itemname == subcat.itemname end)
      |> Enum.filter(fn x -> x.is_delete == 0 end)
      |> Enum.reject(fn x -> String.length(x.itemcatid) > 5 end)

    same_items
    |> Enum.map(fn x -> {x.price_code, Decimal.to_string(x.itemprice)} end)
    |> Enum.sort_by(fn x -> elem(x, 0) end)
    |> Enum.map(fn x ->
      "<span class='badge badge-#{color(elem(x, 0))} #{elem(x, 0)}'>#{elem(x, 1)}</span>"
    end)
    |> Enum.join()
  end

  def color(code) do
    case code do
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
  end
end
