defmodule BoatNoodleWeb.UserChannel do
  use BoatNoodleWeb, :channel
  require IEx

  def join("user:" <> user_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("open_login_modal", payload, socket) do
    broadcast(socket, "open_login_modal", payload)
    {:noreply, socket}
  end

  def handle_in("list_items", %{"item_cat_id" => item_cat_id}, socket) do
    items =
      Repo.all(
        from(
          i in BoatNoodle.BN.ItemSubcat,
          where: i.itemcatid == ^item_cat_id,
          select: %{
            itemcode: i.itemcode,
            product_code: i.product_code,
            itemname: i.itemname,
            itemprice: i.itemprice,
            is_activate: i.is_activate
          }
        )
      )

    # IEx.pry()
    broadcast(socket, "populate_table_items", %{items: items})
    {:noreply, socket}
  end

  defp authorized?(_payload) do
    true
  end
end
