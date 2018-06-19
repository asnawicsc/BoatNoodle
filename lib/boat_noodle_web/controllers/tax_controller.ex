defmodule BoatNoodleWeb.TaxController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.Tax

  def index(conn, _params) do
    branches = Repo.all(from(s in BoatNoodle.BN.Branch))
    render(conn, "index.html", branches: branches)
  end

  def new(conn, _params) do
    changeset = BN.change_tax(%Tax{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tax" => tax_params}) do
    case BN.create_tax(tax_params) do
      {:ok, tax} ->
        conn
        |> put_flash(:info, "Tax created successfully.")
        |> redirect(to: tax_path(conn, :show, tax))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tax = BN.get_tax!(id)
    render(conn, "show.html", tax: tax)
  end

  def edit(conn, %{"id" => id}) do
    tax = BN.get_tax!(id)
    changeset = BN.change_tax(tax)
    render(conn, "edit.html", tax: tax, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tax" => tax_params}) do
    tax = BN.get_tax!(id)

    case BN.update_tax(tax, tax_params) do
      {:ok, tax} ->
        conn
        |> put_flash(:info, "Tax updated successfully.")
        |> redirect(to: tax_path(conn, :show, tax))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", tax: tax, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tax = BN.get_tax!(id)
    {:ok, _tax} = BN.delete_tax(tax)

    conn
    |> put_flash(:info, "Tax deleted successfully.")
    |> redirect(to: tax_path(conn, :index, BN.get_domain(conn)))
  end
end
