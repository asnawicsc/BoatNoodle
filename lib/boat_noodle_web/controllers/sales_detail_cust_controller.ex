defmodule BoatNoodleWeb.SalesDetailCustController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.SalesDetailCust

  def index(conn, _params) do
    salesdetailcust = BN.list_salesdetailcust()
    render(conn, "index.html", salesdetailcust: salesdetailcust)
  end

  def new(conn, _params) do
    changeset = BN.change_sales_detail_cust(%SalesDetailCust{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"sales_detail_cust" => sales_detail_cust_params}) do
    case BN.create_sales_detail_cust(sales_detail_cust_params) do
      {:ok, sales_detail_cust} ->
        conn
        |> put_flash(:info, "Sales detail cust created successfully.")
        |> redirect(to: sales_detail_cust_path(conn, :show, sales_detail_cust))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    sales_detail_cust = BN.get_sales_detail_cust!(id)
    render(conn, "show.html", sales_detail_cust: sales_detail_cust)
  end

  def edit(conn, %{"id" => id}) do
    sales_detail_cust = BN.get_sales_detail_cust!(id)
    changeset = BN.change_sales_detail_cust(sales_detail_cust)
    render(conn, "edit.html", sales_detail_cust: sales_detail_cust, changeset: changeset)
  end

  def update(conn, %{"id" => id, "sales_detail_cust" => sales_detail_cust_params}) do
    sales_detail_cust = BN.get_sales_detail_cust!(id)

    case BN.update_sales_detail_cust(sales_detail_cust, sales_detail_cust_params) do
      {:ok, sales_detail_cust} ->
        conn
        |> put_flash(:info, "Sales detail cust updated successfully.")
        |> redirect(to: sales_detail_cust_path(conn, :show, sales_detail_cust))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", sales_detail_cust: sales_detail_cust, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    sales_detail_cust = BN.get_sales_detail_cust!(id)
    {:ok, _sales_detail_cust} = BN.delete_sales_detail_cust(sales_detail_cust)

    conn
    |> put_flash(:info, "Sales detail cust deleted successfully.")
    |> redirect(to: sales_detail_cust_path(conn, :index))
  end
end
