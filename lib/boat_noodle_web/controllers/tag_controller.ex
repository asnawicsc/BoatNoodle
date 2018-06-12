defmodule BoatNoodleWeb.TagController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.Tag
  require IEx

  def index(conn, _params) do
    tag = BN.list_tag()
    render(conn, "index.html", tag: tag)
  end

  def new(conn, _params) do
    changeset = BN.change_tag(%Tag{})

    branches =
      BN.list_branch()
      |> Enum.map(fn x -> {x.branchname, x.branchid} end)
      |> Enum.reject(fn x -> elem(x, 1) == 0 end)
      |> Enum.sort_by(fn x -> elem(x, 0) end)

    render(conn, "new.html", changeset: changeset, branches: branches)
  end

  def create(conn, %{"tag" => tag_params}) do
    subcat_ids =
      conn.params["subcat_ids"]
      |> Map.keys()
      |> Enum.map(fn x -> String.to_integer(x) end)
      |> Enum.sort()
      |> Enum.map(fn x -> Integer.to_string(x) end)
      |> Enum.join(",")

    tag_params = Map.put(tag_params, "subcat_ids", subcat_ids)
    tag_params = Map.put(tag_params, "branch_id", String.to_integer(tag_params["branch_id"]))

    case BN.create_tag(tag_params) do
      {:ok, tag} ->
        conn
        |> put_flash(:info, "Printer created successfully.")
        |> redirect(to: branch_path(conn, :printers, tag_params["branch_id"]))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Printer creation error.")
        |> redirect(to: tag_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    tag = BN.get_tag!(id)
    render(conn, "show.html", tag: tag)
  end

  def edit(conn, %{"id" => id}) do
    tag = BN.get_tag!(id)
    changeset = BN.change_tag(tag)
    render(conn, "edit.html", tag: tag, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tag" => tag_params}) do
    tag = BN.get_tag!(id)

    case BN.update_tag(tag, tag_params) do
      {:ok, tag} ->
        conn
        |> put_flash(:info, "Printer updated successfully.")
        |> redirect(to: branch_path(conn, :printers, tag.branch_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", tag: tag, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tag = BN.get_tag!(id)
    {:ok, _tag} = BN.delete_tag(tag)

    conn
    |> put_flash(:info, "Tag deleted successfully.")
    |> redirect(to: tag_path(conn, :index))
  end
end
