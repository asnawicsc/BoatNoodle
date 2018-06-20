defmodule BoatNoodleWeb.BrandController do
  use BoatNoodleWeb, :controller
  require IEx
  import Mogrify
  alias BoatNoodle.BN
  alias BoatNoodle.BN.Brand

  def index(conn, _params) do
    brand = Repo.all(from(b in Brand, where: b.id == ^BN.get_brand_id(conn))) |> hd()
    changeset = BN.change_brand(brand)
    render(conn, "index.html", brand: brand, changeset: changeset)
  end

  def new(conn, _params) do
    changeset = BN.change_brand(%Brand{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"brand" => brand_params}) do
    case BN.create_brand(brand_params) do
      {:ok, brand} ->
        conn
        |> put_flash(:info, "Brand created successfully.")
        |> redirect(to: brand_path(conn, :show, brand))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    brand = BN.get_brand!(id)
    render(conn, "show.html", brand: brand)
  end

  def edit(conn, %{"id" => id}) do
    brand = BN.get_brand!(id)
    changeset = BN.change_brand(brand)
    render(conn, "edit.html", brand: brand, changeset: changeset)
  end

  def update(conn, %{"id" => id, "brand" => brand_params}) do
    brand = BN.get_brand!(id)

    case BN.update_brand(brand, brand_params) do
      {:ok, brand} ->
        conn
        |> put_flash(:info, "Brand updated successfully.")
        |> redirect(to: brand_path(conn, :show, brand))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", brand: brand, changeset: changeset)
    end
  end

  def update_brand(conn, params) do
    brand = Repo.get(Brand, BN.get_brand_id(conn))
    brand_params = %{domain_name: params["domain_name"], name: params["name"]}

    case BN.update_brand(brand, brand_params) do
      {:ok, brand} ->
        conn
        |> put_flash(:info, "Brand updated successfully.")
        |> redirect(to: brand_path(conn, :index, brand))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", brand: brand, changeset: changeset)
    end
  end

  def update_brand_logo(conn, params) do
    {:ok, seconds} = Timex.format(Timex.now(), "%s", :strftime)
    brand = Repo.get(Brand, BN.get_brand_id(conn))

    if params["image"] == nil do
      conn
      |> put_flash(:error, "Brand logo does not exists.")
      |> redirect(to: brand_path(conn, :index, brand))
    else
      path = File.cwd!() <> "/media"

      if File.exists?(path) == false do
        File.mkdir(File.cwd!() <> "/media")
      end

      if brand.file_name != nil do
        old_pic_path = path <> brand.file_name
        File.rm(old_pic_path)
      end

      file_name = params["image"].filename |> String.replace(" ", "_")
      file_name = "/#{seconds <> file_name}"
      image_path = path <> file_name
      File.cp(params["image"].path, image_path)

      resized =
        Mogrify.open(image_path)
        |> resize("400x400")
        |> save(path: image_path)

      {:ok, bin} = File.read(image_path)

      brand_params = %{file_name: file_name, bin: Base.encode64(bin)}

      case BN.update_brand(brand, brand_params) do
        {:ok, brand} ->
          conn
          |> put_flash(:info, "Brand logo updated successfully.")
          |> redirect(to: brand_path(conn, :index, brand))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", brand: brand, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    brand = BN.get_brand!(id)
    {:ok, _brand} = BN.delete_brand(brand)

    conn
    |> put_flash(:info, "Brand deleted successfully.")
    |> redirect(to: brand_path(conn, :index, BN.get_domain(conn)))
  end
end
