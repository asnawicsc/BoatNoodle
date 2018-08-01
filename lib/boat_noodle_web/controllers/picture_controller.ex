defmodule BoatNoodleWeb.PictureController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.Images
  alias BoatNoodle.Images.Picture

  def index(conn, _params) do
    picture = Images.list_picture()
    render(conn, "index.html", picture: picture)
  end

  def new(conn, _params) do
    changeset = BoatNoodle.Images.Picture.changeset(%BoatNoodle.Images.Picture{},%{},BN.current_user(conn),"new")
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"picture" => picture_params}) do

    changeset=BoatNoodle.Images.Picture.changeset(%BoatNoodle.Images.Picture{},picture_params,BN.current_user(conn),"Create")

    case BoatNoodle.Repo.insert(changeset) do
      {:ok, picture} ->
        conn
        |> put_flash(:info, "Picture created successfully.")
        |> redirect(to: picture_path(conn, :show, picture))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    picture = Images.get_picture!(id)
    render(conn, "show.html", picture: picture)
  end

  def edit(conn, %{"id" => id}) do
    picture = Images.get_picture!(id)
       changeset=BoatNoodle.Images.Picture.changeset(picture,%{}, BN.current_user(conn),"edit")
    render(conn, "edit.html", picture: picture, changeset: changeset)
  end

  def update(conn, %{"id" => id, "picture" => picture_params}) do
    picture = Images.get_picture!(id)

    changeset=BoatNoodle.Images.Picture.changeset(picture,picture_params, BN.current_user(conn),"Update")

    case BoatNoodle.Repo.update(changeset) do
      {:ok, picture} ->
        conn
        |> put_flash(:info, "Picture updated successfully.")
        |> redirect(to: picture_path(conn, :show, picture))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", picture: picture, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    picture = Images.get_picture!(id)
    {:ok, _picture} = Images.delete_picture(picture)

    conn
    |> put_flash(:info, "Picture deleted successfully.")
    |> redirect(to: picture_path(conn, :index, BN.get_domain(conn)))
  end
end
