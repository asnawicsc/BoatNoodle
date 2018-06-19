defmodule BoatNoodleWeb.SalesPaymentController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.SalesPayment

  def index(conn, _params) do
    salespayment = Repo.all(from(sp in SalesPayment, limit: 100))
    render(conn, "index.html", salespayment: salespayment)
  end

  def new(conn, _params) do
    changeset = BN.change_sales_payment(%SalesPayment{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"sales_payment" => sales_payment_params}) do
    case BN.create_sales_payment(sales_payment_params) do
      {:ok, sales_payment} ->
        conn
        |> put_flash(:info, "Sales payment created successfully.")
        |> redirect(to: sales_payment_path(conn, :show, sales_payment))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    sales_payment = BN.get_sales_payment!(id)
    render(conn, "show.html", sales_payment: sales_payment)
  end

  def edit(conn, %{"id" => id}) do
    sales_payment = BN.get_sales_payment!(id)
    changeset = BN.change_sales_payment(sales_payment)
    render(conn, "edit.html", sales_payment: sales_payment, changeset: changeset)
  end

  def update(conn, %{"id" => id, "sales_payment" => sales_payment_params}) do
    sales_payment = BN.get_sales_payment!(id)

    case BN.update_sales_payment(sales_payment, sales_payment_params) do
      {:ok, sales_payment} ->
        conn
        |> put_flash(:info, "Sales payment updated successfully.")
        |> redirect(to: sales_payment_path(conn, :show, sales_payment))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", sales_payment: sales_payment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    sales_payment = BN.get_sales_payment!(id)
    {:ok, _sales_payment} = BN.delete_sales_payment(sales_payment)

    conn
    |> put_flash(:info, "Sales payment deleted successfully.")
    |> redirect(to: sales_payment_path(conn, :index, BN.get_domain(conn)))
  end
end
