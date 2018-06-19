defmodule BoatNoodleWeb.DiscountTypeController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.DiscountType

  def index(conn, _params) do
    discount_type = BN.list_discount_type()
    render(conn, "index.html", discount_type: discount_type)
  end

  def new(conn, _params) do
    changeset = BN.change_discount_type(%DiscountType{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"discount_type" => discount_type_params}) do
    case BN.create_discount_type(discount_type_params) do
      {:ok, discount_type} ->
        conn
        |> put_flash(:info, "Discount type created successfully.")
        |> redirect(to: discount_type_path(conn, :show, discount_type))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    discount_type = BN.get_discount_type!(id)
    render(conn, "show.html", discount_type: discount_type)
  end

  def edit(conn, %{"id" => id}) do
    discount_type = BN.get_discount_type!(id)
    changeset = BN.change_discount_type(discount_type)
    render(conn, "edit.html", discount_type: discount_type, changeset: changeset)
  end

  def update(conn, %{"id" => id, "discount_type" => discount_type_params}) do
    discount_type = BN.get_discount_type!(id)

    case BN.update_discount_type(discount_type, discount_type_params) do
      {:ok, discount_type} ->
        conn
        |> put_flash(:info, "Discount type updated successfully.")
        |> redirect(to: discount_type_path(conn, :show, discount_type))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", discount_type: discount_type, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    discount_type = BN.get_discount_type!(id)
    {:ok, _discount_type} = BN.delete_discount_type(discount_type)

    conn
    |> put_flash(:info, "Discount type deleted successfully.")
    |> redirect(to: discount_type_path(conn, :index, BN.get_domain(conn)))
  end
end
