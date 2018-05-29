defmodule BoatNoodleWeb.MenuItemView do
  use BoatNoodleWeb, :view
  alias BoatNoodle.Repo
  alias BoatNoodle.BN.ItemSubcat
   alias BoatNoodle.BN.ItemCat
  import Ecto.Query
  require IEx

  def item_subcats(ids) do
    ids =
      String.split(ids, ",") |> Enum.reject(fn x -> x == "" end)
      |> Enum.map(fn x -> String.to_integer(x) end)

    Repo.all(from(i in ItemSubcat, left_join: c in ItemCat, on: c.itemcatid == i.itemcatid,
     where: i.subcatid in ^ids, select: %{
      itemcatid: i.itemcatid, 
      catname: c.itemcatname,
     itemname: i.itemname, 
     itemprice: i.itemprice,
     subcatid: i.subcatid}))
    # |> Enum.group_by(fn x -> x.itemcatid end)
  end
end
