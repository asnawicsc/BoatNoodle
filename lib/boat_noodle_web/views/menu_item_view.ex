defmodule BoatNoodleWeb.MenuItemView do
  use BoatNoodleWeb, :view
  alias BoatNoodle.Repo
  alias BoatNoodle.BN.ItemSubcat
  import Ecto.Query
  require IEx

  def item_subcats(ids) do
    ids =
      String.split(ids, ",") |> Enum.reject(fn x -> x == "" end)
      |> Enum.map(fn x -> String.to_integer(x) end)

    Repo.all(from(i in ItemSubcat, where: i.subcatid in ^ids))
    |> Enum.group_by(fn x -> x.itemcatid end)
  end
end
