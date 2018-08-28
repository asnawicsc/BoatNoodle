defmodule BoatNoodleWeb.MenuItemView do
  use BoatNoodleWeb, :view
  alias BoatNoodle.Repo
  alias BoatNoodle.BN.{ItemCat, Brand, ItemSubcat}

  import Ecto.Query
  require IEx

  def item_subcats(ids) do
    ids =
      String.split(ids, ",") |> Enum.reject(fn x -> x == "" end)
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

  def pricing(subcatid, brand) do
    subcat =
      Repo.get_by(
        ItemSubcat,
        subcatid: subcatid,
        brand_id: brand.private.plug_session["brand_id"]
      )

    same_items =
      Repo.all(
        from(
          i in ItemSubcat,
          where:
            i.itemname == ^subcat.itemname and i.is_delete == ^0 and i.itemprice != 0.00 and
              i.brand_id == ^brand.private.plug_session["brand_id"]
        )
      )
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
