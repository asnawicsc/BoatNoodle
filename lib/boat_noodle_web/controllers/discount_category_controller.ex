defmodule BoatNoodleWeb.DiscountCategoryController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.DiscountCategory

  def index(conn, _params) do
    discount_category = BN.list_discount_category()
    render(conn, "index.html", discount_category: discount_category)
  end

  def new(conn, _params) do
    changeset = BN.change_discount_category(%DiscountCategory{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"discount_category" => discount_category_params}) do
    case BN.create_discount_category(discount_category_params) do
      {:ok, discount_category} ->
        conn
        |> put_flash(:info, "Discount category created successfully.")
        |> redirect(to: discount_category_path(conn, :show, discount_category))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    discount_category = BN.get_discount_category!(id)
    render(conn, "show.html", discount_category: discount_category)
  end

  def edit(conn, %{"id" => id}) do
    discount_category = BN.get_discount_category!(id)
    changeset = BN.change_discount_category(discount_category)
    render(conn, "edit.html", discount_category: discount_category, changeset: changeset)
  end

  def update(conn, %{"id" => id, "discount_category" => discount_category_params}) do
    discount_category = BN.get_discount_category!(id)

    case BN.update_discount_category(discount_category, discount_category_params) do
      {:ok, discount_category} ->
        conn
        |> put_flash(:info, "Discount category updated successfully.")
        |> redirect(to: discount_category_path(conn, :show, discount_category))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", discount_category: discount_category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    discount_category = BN.get_discount_category!(id)
    {:ok, _discount_category} = BN.delete_discount_category(discount_category)

    conn
    |> put_flash(:info, "Discount category deleted successfully.")
    |> redirect(to: discount_category_path(conn, :index))
  end
end
