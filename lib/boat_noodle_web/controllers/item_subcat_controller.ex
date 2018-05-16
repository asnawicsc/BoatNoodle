defmodule BoatNoodleWeb.ItemSubcatController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.ItemSubcat

  def index(conn, _params) do
    item_subcat = BN.list_item_subcat()
    render(conn, "index.html", item_subcat: item_subcat)
  end

  def new(conn, _params) do
    changeset = BN.change_item_subcat(%ItemSubcat{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"item_subcat" => item_subcat_params}) do
    case BN.create_item_subcat(item_subcat_params) do
      {:ok, item_subcat} ->
        conn
        |> put_flash(:info, "Item subcat created successfully.")
        |> redirect(to: item_subcat_path(conn, :show, item_subcat))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    item_subcat = BN.get_item_subcat!(id)
    render(conn, "show.html", item_subcat: item_subcat)
  end

  def edit(conn, %{"id" => id}) do
    item_subcat = BN.get_item_subcat!(id)
    changeset = BN.change_item_subcat(item_subcat)
    render(conn, "edit.html", item_subcat: item_subcat, changeset: changeset)
  end

  def update(conn, %{"id" => id, "item_subcat" => item_subcat_params}) do
    item_subcat = BN.get_item_subcat!(id)

    case BN.update_item_subcat(item_subcat, item_subcat_params) do
      {:ok, item_subcat} ->
        conn
        |> put_flash(:info, "Item subcat updated successfully.")
        |> redirect(to: item_subcat_path(conn, :show, item_subcat))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", item_subcat: item_subcat, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    item_subcat = BN.get_item_subcat!(id)
    {:ok, _item_subcat} = BN.delete_item_subcat(item_subcat)

    conn
    |> put_flash(:info, "Item subcat deleted successfully.")
    |> redirect(to: item_subcat_path(conn, :index))
  end
end
