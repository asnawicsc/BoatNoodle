defmodule BoatNoodleWeb.VoidItemsController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.VoidItems

  def index(conn, _params) do
    voiditems = Repo.all(from(v in VoidItems, limit: 10))
    render(conn, "index.html", voiditems: voiditems)
  end

  def new(conn, _params) do
    changeset = BN.change_void_items(%VoidItems{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"void_items" => void_items_params}) do
    case BN.create_void_items(void_items_params) do
      {:ok, void_items} ->
        conn
        |> put_flash(:info, "Void items created successfully.")
        |> redirect(to: void_items_path(conn, :show, void_items))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    void_items = BN.get_void_items!(id)
    render(conn, "show.html", void_items: void_items)
  end

  def edit(conn, %{"id" => id}) do
    void_items = BN.get_void_items!(id)
    changeset = BN.change_void_items(void_items)
    render(conn, "edit.html", void_items: void_items, changeset: changeset)
  end

  def update(conn, %{"id" => id, "void_items" => void_items_params}) do
    void_items = BN.get_void_items!(id)

    case BN.update_void_items(void_items, void_items_params) do
      {:ok, void_items} ->
        conn
        |> put_flash(:info, "Void items updated successfully.")
        |> redirect(to: void_items_path(conn, :show, void_items))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", void_items: void_items, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    void_items = BN.get_void_items!(id)
    {:ok, _void_items} = BN.delete_void_items(void_items)

    conn
    |> put_flash(:info, "Void items deleted successfully.")
    |> redirect(to: void_items_path(conn, :index, BN.get_domain(conn)))
  end
end
