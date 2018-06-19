defmodule BoatNoodleWeb.ComboDetailsController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.ComboDetails

  def index(conn, _params) do
    combo_details = BN.list_combo_details()
    render(conn, "index.html", combo_details: combo_details)
  end

  def new(conn, _params) do
    changeset = BN.change_combo_details(%ComboDetails{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"combo_details" => combo_details_params}) do
    case BN.create_combo_details(combo_details_params) do
      {:ok, combo_details} ->
        conn
        |> put_flash(:info, "Combo details created successfully.")
        |> redirect(to: combo_details_path(conn, :show, combo_details))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    combo_details = BN.get_combo_details!(id)
    render(conn, "show.html", combo_details: combo_details)
  end

  def edit(conn, %{"id" => id}) do
    combo_details = BN.get_combo_details!(id)
    changeset = BN.change_combo_details(combo_details)
    render(conn, "edit.html", combo_details: combo_details, changeset: changeset)
  end

  def update(conn, %{"id" => id, "combo_details" => combo_details_params}) do
    combo_details = BN.get_combo_details!(id)

    case BN.update_combo_details(combo_details, combo_details_params) do
      {:ok, combo_details} ->
        conn
        |> put_flash(:info, "Combo details updated successfully.")
        |> redirect(to: combo_details_path(conn, :show, combo_details))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", combo_details: combo_details, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    combo_details = BN.get_combo_details!(id)
    {:ok, _combo_details} = BN.delete_combo_details(combo_details)

    conn
    |> put_flash(:info, "Combo details deleted successfully.")
    |> redirect(to: combo_details_path(conn, :index, BN.get_domain(conn)))
  end
end
