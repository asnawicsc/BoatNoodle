defmodule BoatNoodleWeb.TagItemsController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.TagItems

  def index(conn, _params) do
    tag_items = Repo.all(TagItems)
    render(conn, "index.html", tag_items: tag_items)
  end

  def new(conn, _params) do
    changeset = BN.change_tag_items(%TagItems{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tag_items" => tag_items_params}) do
    case BN.create_tag_items(tag_items_params) do
      {:ok, tag_items} ->
        conn
        |> put_flash(:info, "Tag items created successfully.")
        |> redirect(to: tag_items_path(conn, :show, tag_items))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tag_items = BN.get_tag_items!(id)
    render(conn, "show.html", tag_items: tag_items)
  end

  def edit(conn, %{"id" => id}) do
    tag_items = BN.get_tag_items!(id)
    changeset = BN.change_tag_items(tag_items)
    render(conn, "edit.html", tag_items: tag_items, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tag_items" => tag_items_params}) do
    tag_items = BN.get_tag_items!(id)

    case BN.update_tag_items(tag_items, tag_items_params) do
      {:ok, tag_items} ->
        conn
        |> put_flash(:info, "Tag items updated successfully.")
        |> redirect(to: tag_items_path(conn, :show, tag_items))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", tag_items: tag_items, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tag_items = BN.get_tag_items!(id)
    {:ok, _tag_items} = BN.delete_tag_items(tag_items)

    conn
    |> put_flash(:info, "Tag items deleted successfully.")
    |> redirect(to: tag_items_path(conn, :index))
  end
end
