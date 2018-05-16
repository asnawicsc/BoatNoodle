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

  def handle_in("sales_transaction", payload, socket) do
    IEx.pry()

    sales_data =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: s.salesid == sp.salesid,
          left_join: st in BoatNoodle.BN.Staff,
          on: s.staffid == st.staff_id,
          where: s.branchid == "1",
          select: %{
            salesdatetime: s.salesdatetime,
            invoiceno: s.invoiceno,
            payment_type: sp.payment_type,
            grand_total: sp.grand_total,
            tbl_no: s.tbl_no,
            pax: s.pax,
            staff_name: st.staff_name
          },
          limit: 10
        )
      )

    broadcast(socket, "populate_table_sales_transaction", %{sales_data: sales_data})
    {:noreply, socket}
  end

  defp authorized?(_payload) do
    true
  end
end
