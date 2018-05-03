defmodule BoatNoodleWeb.DiscountCatalogController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.DiscountCatalog

  def index(conn, _params) do
    discount_catalog = Repo.all(DiscountCatalog)
    render(conn, "index.html", discount_catalog: discount_catalog)
  end

  def new(conn, _params) do
    changeset = BN.change_discount_catalog(%DiscountCatalog{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"discount_catalog" => discount_catalog_params}) do
    case BN.create_discount_catalog(discount_catalog_params) do
      {:ok, discount_catalog} ->
        conn
        |> put_flash(:info, "Discount catalog created successfully.")
        |> redirect(to: discount_catalog_path(conn, :show, discount_catalog))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    discount_catalog = BN.get_discount_catalog!(id)
    render(conn, "show.html", discount_catalog: discount_catalog)
  end

  def edit(conn, %{"id" => id}) do
    discount_catalog = BN.get_discount_catalog!(id)
    changeset = BN.change_discount_catalog(discount_catalog)
    render(conn, "edit.html", discount_catalog: discount_catalog, changeset: changeset)
  end

  def update(conn, %{"id" => id, "discount_catalog" => discount_catalog_params}) do
    discount_catalog = BN.get_discount_catalog!(id)

    case BN.update_discount_catalog(discount_catalog, discount_catalog_params) do
      {:ok, discount_catalog} ->
        conn
        |> put_flash(:info, "Discount catalog updated successfully.")
        |> redirect(to: discount_catalog_path(conn, :show, discount_catalog))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", discount_catalog: discount_catalog, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    discount_catalog = BN.get_discount_catalog!(id)
    {:ok, _discount_catalog} = BN.delete_discount_catalog(discount_catalog)

    conn
    |> put_flash(:info, "Discount catalog deleted successfully.")
    |> redirect(to: discount_catalog_path(conn, :index))
  end
end
