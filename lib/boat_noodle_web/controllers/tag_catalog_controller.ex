defmodule BoatNoodleWeb.TagCatalogController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.TagCatalog

  def index(conn, _params) do
    tag_catalog = BN.list_tag_catalog()
    render(conn, "index.html", tag_catalog: tag_catalog)
  end

  def new(conn, _params) do
    changeset = BN.change_tag_catalog(%TagCatalog{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tag_catalog" => tag_catalog_params}) do
    case BN.create_tag_catalog(tag_catalog_params) do
      {:ok, tag_catalog} ->
        conn
        |> put_flash(:info, "Tag catalog created successfully.")
        |> redirect(to: tag_catalog_path(conn, :show, tag_catalog))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tag_catalog = BN.get_tag_catalog!(id)
    render(conn, "show.html", tag_catalog: tag_catalog)
  end

  def edit(conn, %{"id" => id}) do
    tag_catalog = BN.get_tag_catalog!(id)
    changeset = BN.change_tag_catalog(tag_catalog)
    render(conn, "edit.html", tag_catalog: tag_catalog, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tag_catalog" => tag_catalog_params}) do
    tag_catalog = BN.get_tag_catalog!(id)

    case BN.update_tag_catalog(tag_catalog, tag_catalog_params) do
      {:ok, tag_catalog} ->
        conn
        |> put_flash(:info, "Tag catalog updated successfully.")
        |> redirect(to: tag_catalog_path(conn, :show, tag_catalog))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", tag_catalog: tag_catalog, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tag_catalog = BN.get_tag_catalog!(id)
    {:ok, _tag_catalog} = BN.delete_tag_catalog(tag_catalog)

    conn
    |> put_flash(:info, "Tag catalog deleted successfully.")
    |> redirect(to: tag_catalog_path(conn, :index))
  end
end
