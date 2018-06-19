defmodule BoatNoodleWeb.ItemCatController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.ItemCat

  def index(conn, _params) do
    itemcat = BN.list_itemcat()
    render(conn, "index.html", itemcat: itemcat)
  end

  def new(conn, _params) do
    changeset = BN.change_item_cat(%ItemCat{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"item_cat" => item_cat_params}) do
    case BN.create_item_cat(item_cat_params) do
      {:ok, item_cat} ->
        conn
        |> put_flash(:info, "Item cat created successfully.")
        |> redirect(to: item_cat_path(conn, :show, item_cat))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    item_cat = BN.get_item_cat!(id)
    render(conn, "show.html", item_cat: item_cat)
  end

  def edit(conn, %{"id" => id}) do
    item_cat = BN.get_item_cat!(id)
    changeset = BN.change_item_cat(item_cat)
    render(conn, "edit.html", item_cat: item_cat, changeset: changeset)
  end

  def update(conn, %{"id" => id, "item_cat" => item_cat_params}) do
    item_cat = BN.get_item_cat!(id)

    case BN.update_item_cat(item_cat, item_cat_params) do
      {:ok, item_cat} ->
        conn
        |> put_flash(:info, "Item cat updated successfully.")
        |> redirect(to: item_cat_path(conn, :show, item_cat))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", item_cat: item_cat, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    item_cat = BN.get_item_cat!(id)
    {:ok, _item_cat} = BN.delete_item_cat(item_cat)

    conn
    |> put_flash(:info, "Item cat deleted successfully.")
    |> redirect(to: item_cat_path(conn, :index, BN.get_domain(conn)))
  end
end
