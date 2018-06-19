defmodule BoatNoodleWeb.DiscountCatalogMasterController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.DiscountCatalogMaster

  def index(conn, _params) do
    discount_catalog_master = Repo.all(DiscountCatalogMaster)
    render(conn, "index.html", discount_catalog_master: discount_catalog_master)
  end

  def new(conn, _params) do
    changeset = BN.change_discount_catalog_master(%DiscountCatalogMaster{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"discount_catalog_master" => discount_catalog_master_params}) do
    case BN.create_discount_catalog_master(discount_catalog_master_params) do
      {:ok, discount_catalog_master} ->
        conn
        |> put_flash(:info, "Discount catalog master created successfully.")
        |> redirect(to: discount_catalog_master_path(conn, :show, discount_catalog_master))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    discount_catalog_master = BN.get_discount_catalog_master!(id)
    render(conn, "show.html", discount_catalog_master: discount_catalog_master)
  end

  def edit(conn, %{"id" => id}) do
    discount_catalog_master = BN.get_discount_catalog_master!(id)
    changeset = BN.change_discount_catalog_master(discount_catalog_master)

    render(
      conn,
      "edit.html",
      discount_catalog_master: discount_catalog_master,
      changeset: changeset
    )
  end

  def update(conn, %{"id" => id, "discount_catalog_master" => discount_catalog_master_params}) do
    discount_catalog_master = BN.get_discount_catalog_master!(id)

    case BN.update_discount_catalog_master(
           discount_catalog_master,
           discount_catalog_master_params
         ) do
      {:ok, discount_catalog_master} ->
        conn
        |> put_flash(:info, "Discount catalog master updated successfully.")
        |> redirect(to: discount_catalog_master_path(conn, :show, discount_catalog_master))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "edit.html",
          discount_catalog_master: discount_catalog_master,
          changeset: changeset
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    discount_catalog_master = BN.get_discount_catalog_master!(id)
    {:ok, _discount_catalog_master} = BN.delete_discount_catalog_master(discount_catalog_master)

    conn
    |> put_flash(:info, "Discount catalog master deleted successfully.")
    |> redirect(to: discount_catalog_master_path(conn, :index, BN.get_domain(conn)))
  end
end
