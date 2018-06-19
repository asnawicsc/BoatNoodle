defmodule BoatNoodleWeb.RemarkController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.Remark

  def index(conn, _params) do
    remark = Repo.all(Remark)
    render(conn, "index.html", remark: remark)
  end

  def new(conn, _params) do
    changeset = BN.change_remark(%Remark{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"remark" => remark_params}) do
    case BN.create_remark(remark_params) do
      {:ok, remark} ->
        conn
        |> put_flash(:info, "Remark created successfully.")
        |> redirect(to: remark_path(conn, :show, remark))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    remark = BN.get_remark!(id)
    render(conn, "show.html", remark: remark)
  end

  def edit(conn, %{"id" => id}) do
    remark = BN.get_remark!(id)
    changeset = BN.change_remark(remark)
    render(conn, "edit.html", remark: remark, changeset: changeset)
  end

  def update(conn, %{"id" => id, "remark" => remark_params}) do
    remark = BN.get_remark!(id)

    case BN.update_remark(remark, remark_params) do
      {:ok, remark} ->
        conn
        |> put_flash(:info, "Remark updated successfully.")
        |> redirect(to: remark_path(conn, :show, remark))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", remark: remark, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    remark = BN.get_remark!(id)
    {:ok, _remark} = BN.delete_remark(remark)

    conn
    |> put_flash(:info, "Remark deleted successfully.")
    |> redirect(to: remark_path(conn, :index, BN.get_domain(conn)))
  end
end
