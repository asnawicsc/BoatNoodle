defmodule BoatNoodleWeb.DiscountItemController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.DiscountItem

  def index(conn, _params) do
    discount_item = BN.list_discount_item()
    render(conn, "index.html", discount_item: discount_item)
  end

  def new(conn, _params) do
    changeset = BN.change_discount_item(%DiscountItem{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"discount_item" => discount_item_params}) do
    case BN.create_discount_item(discount_item_params) do
      {:ok, discount_item} ->
        conn
        |> put_flash(:info, "Discount item created successfully.")
        |> redirect(to: discount_item_path(conn, :show, discount_item))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    discount_item = BN.get_discount_item!(id)
    render(conn, "show.html", discount_item: discount_item)
  end

  def edit(conn, %{"id" => id}) do
    discount_item = BN.get_discount_item!(id)
    changeset = BN.change_discount_item(discount_item)
    render(conn, "edit.html", discount_item: discount_item, changeset: changeset)
  end

  def update(conn, %{"id" => id, "discount_item" => discount_item_params}) do
    discount_item = BN.get_discount_item!(id)

    case BN.update_discount_item(discount_item, discount_item_params) do
      {:ok, discount_item} ->
        conn
        |> put_flash(:info, "Discount item updated successfully.")
        |> redirect(to: discount_item_path(conn, :show, discount_item))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", discount_item: discount_item, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    discount_item = BN.get_discount_item!(id)
    {:ok, _discount_item} = BN.delete_discount_item(discount_item)

    conn
    |> put_flash(:info, "Discount item deleted successfully.")
    |> redirect(to: discount_item_path(conn, :index))
  end
end
