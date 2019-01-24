defmodule BoatNoodleWeb.SalesDetailComboController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.SalesDetailCombo

  def index(conn, _params) do
    sales_detail_combo = BN.list_sales_detail_combo()
    render(conn, "index.html", sales_detail_combo: sales_detail_combo)
  end

  def new(conn, _params) do
    changeset = BN.change_sales_detail_combo(%SalesDetailCombo{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"sales_detail_combo" => sales_detail_combo_params}) do
    case BN.create_sales_detail_combo(sales_detail_combo_params) do
      {:ok, sales_detail_combo} ->
        conn
        |> put_flash(:info, "Sales detail combo created successfully.")
        |> redirect(to: sales_detail_combo_path(conn, :show, sales_detail_combo))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    sales_detail_combo = BN.get_sales_detail_combo!(id)
    render(conn, "show.html", sales_detail_combo: sales_detail_combo)
  end

  def edit(conn, %{"id" => id}) do
    sales_detail_combo = BN.get_sales_detail_combo!(id)
    changeset = BN.change_sales_detail_combo(sales_detail_combo)
    render(conn, "edit.html", sales_detail_combo: sales_detail_combo, changeset: changeset)
  end

  def update(conn, %{"id" => id, "sales_detail_combo" => sales_detail_combo_params}) do
    sales_detail_combo = BN.get_sales_detail_combo!(id)

    case BN.update_sales_detail_combo(sales_detail_combo, sales_detail_combo_params) do
      {:ok, sales_detail_combo} ->
        conn
        |> put_flash(:info, "Sales detail combo updated successfully.")
        |> redirect(to: sales_detail_combo_path(conn, :show, sales_detail_combo))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", sales_detail_combo: sales_detail_combo, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    sales_detail_combo = BN.get_sales_detail_combo!(id)
    {:ok, _sales_detail_combo} = BN.delete_sales_detail_combo(sales_detail_combo)

    conn
    |> put_flash(:info, "Sales detail combo deleted successfully.")
    |> redirect(to: sales_detail_combo_path(conn, :index, BN.get_brand_id(conn)))
  end
end
