defmodule BoatNoodleWeb.ItemCustomizedController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.ItemCustomized

  def index(conn, _params) do
    item_customized = BN.list_item_customized()
    render(conn, "index.html", item_customized: item_customized)
  end

  def new(conn, _params) do
    changeset = BN.change_item_customized(%ItemCustomized{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"item_customized" => item_customized_params}) do
    case BN.create_item_customized(item_customized_params) do
      {:ok, item_customized} ->
        conn
        |> put_flash(:info, "Item customized created successfully.")
        |> redirect(to: item_customized_path(conn, :show, item_customized))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    item_customized = BN.get_item_customized!(id)
    render(conn, "show.html", item_customized: item_customized)
  end

  def edit(conn, %{"id" => id}) do
    item_customized = BN.get_item_customized!(id)
    changeset = BN.change_item_customized(item_customized)
    render(conn, "edit.html", item_customized: item_customized, changeset: changeset)
  end

  def update(conn, %{"id" => id, "item_customized" => item_customized_params}) do
    item_customized = BN.get_item_customized!(id)

    case BN.update_item_customized(item_customized, item_customized_params) do
      {:ok, item_customized} ->
        conn
        |> put_flash(:info, "Item customized updated successfully.")
        |> redirect(to: item_customized_path(conn, :show, item_customized))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", item_customized: item_customized, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    item_customized = BN.get_item_customized!(id)
    {:ok, _item_customized} = BN.delete_item_customized(item_customized)

    conn
    |> put_flash(:info, "Item customized deleted successfully.")
    |> redirect(to: item_customized_path(conn, :index, BN.get_domain(conn)))
  end
end
