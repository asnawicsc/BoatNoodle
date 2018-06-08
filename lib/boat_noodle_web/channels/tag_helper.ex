defmodule BoatNoodleWeb.TagHelper do
  use BoatNoodleWeb, :channel
  require IEx

  def join("tag:" <> user_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("query_branch_subcats", %{"id" => id}, socket) do
    branch = BN.get_branch!(id)
    menu_cat = Repo.get(MenuCatalog, branch.menu_catalog)

    item_ids = menu_cat.items |> String.split(",") |> Enum.reject(fn x -> x == "" end)
    combo_ids = menu_cat.combo_items |> String.split(",") |> Enum.reject(fn x -> x == "" end)

    subcats =
      Repo.all(
        from(
          s in ItemSubcat,
          where: s.subcatid in ^item_ids,
          select: %{
            id: s.subcatid,
            name: s.itemname
          },
          order_by: [asc: s.itemname]
        )
      )

    html =
      Phoenix.View.render_to_string(
        BoatNoodleWeb.TagView,
        "subcat_checkbox.html",
        subcats: subcats
      )

    broadcast(socket, "show_branch_subcats", %{item_ids: item_ids, html: html})
    {:noreply, socket}
  end

  defp authorized?(_payload) do
    true
  end
end
