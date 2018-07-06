defmodule BoatNoodleWeb.SalesMasterController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.SalesMaster
  require IEx

  defp branches() do
    Repo.all(from(s in BoatNoodle.BN.Branch,order_by: [asc: s.branchname]))
    |> Enum.reject(fn x -> x.branchid == 0 end)
  end

  def index(conn, _params) do
     branches = Repo.all(from(s in BoatNoodle.BN.Branch , where: s.brand_id==^BN.get_brand_id(conn)))
    render(conn, "index.html", branches: branches)
  end

  def new(conn, _params) do
    changeset = BN.change_sales_master(%SalesMaster{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"sales_master" => sales_master_params}) do
    case BN.create_sales_master(sales_master_params) do
      {:ok, sales_master} ->
        conn
        |> put_flash(:info, "Sales master created successfully.")
        |> redirect(to: sales_master_path(conn, :show, sales_master))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    sales_master = BN.get_sales_master!(id)
    render(conn, "show.html", sales_master: sales_master)
  end

  def edit(conn, %{"id" => id}) do
    sales_master = BN.get_sales_master!(id)
    changeset = BN.change_sales_master(sales_master)
    render(conn, "edit.html", sales_master: sales_master, changeset: changeset)
  end

  def update(conn, %{"id" => id, "sales_master" => sales_master_params}) do
    sales_master = BN.get_sales_master!(id)

    case BN.update_sales_master(sales_master, sales_master_params) do
      {:ok, sales_master} ->
        conn
        |> put_flash(:info, "Sales master updated successfully.")
        |> redirect(to: sales_master_path(conn, :show, sales_master))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", sales_master: sales_master, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    sales_master = BN.get_sales_master!(id)
    {:ok, _sales_master} = BN.delete_sales_master(sales_master)

    conn
    |> put_flash(:info, "Sales master deleted successfully.")
    |> redirect(to: sales_master_path(conn, :index, BN.get_domain(conn)))
  end
end
