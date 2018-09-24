defmodule BoatNoodleWeb.BrandController do
  use BoatNoodleWeb, :controller
  require IEx
  import Mogrify
  alias BoatNoodle.BN
  alias BoatNoodle.BN.Brand

  def index(conn, _params) do
    brand = Repo.all(from(b in Brand, where: b.id == ^BN.get_brand_id(conn))) |> hd()
    changeset = Brand.changeset(%BoatNoodle.BN.Brand{}, %{}, BN.current_user(conn), "new")
    render(conn, "index.html", brand: brand, changeset: changeset)
  end

  def new(conn, _params) do
    changeset = Brand.changeset(%BoatNoodle.BN.Brand{}, %{}, BN.current_user(conn), "new")
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params) do
    brand_params = %{}

    brand_params = Map.put(brand_params, "name", params["name"])
    brand_params = Map.put(brand_params, "domain_name", params["domain_name"])
    brand_params = Map.put(brand_params, "bin", params["bin"])

    changeset =
      BoatNoodle.BN.Brand.changeset(
        %BoatNoodle.BN.Brand{},
        brand_params,
        BN.current_user(conn),
        "Create"
      )

    case BoatNoodle.Repo.insert(changeset) do
      {:ok, brand} ->
        conn
        |> put_flash(:info, "Brand created successfully.")
        |> redirect(to: brand_path(conn, :index, BN.get_domain(conn)))

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
    changeset = BoatNoodle.BN.Brand.changeset(brand, %{}, BN.current_user(conn), "edit")
    render(conn, "edit.html", brand: brand, changeset: changeset)
  end

  def update(conn, %{"id" => id, "brand" => brand_params}) do
    brand = BN.get_brand!(id)

    changeset =
      BoatNoodle.BN.Brand.changeset(brand, brand_params, BN.current_user(conn), "Update")

    case BoatNoodle.Repo.update(changeset) do
      {:ok, brand} ->
        conn
        |> put_flash(:info, "Brand updated successfully.")
        |> redirect(to: brand_path(conn, :show, BN.get_domain(conn), brand))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", brand: brand, changeset: changeset)
    end
  end

  def update_brand(conn, params) do
    brand = Repo.get(Brand, BN.get_brand_id(conn))

    brand_params = %{
      domain_name: params["domain_name"],
      name: params["name"],
      tax_code: params["tax_code"]
    }

    changeset =
      BoatNoodle.BN.Brand.changeset(brand, brand_params, BN.current_user(conn), "Update")

    case BoatNoodle.Repo.update(changeset) do
      {:ok, brand} ->
        conn
        |> put_flash(:info, "Brand updated successfully.")
        |> redirect(to: brand_path(conn, :index, BN.get_domain(conn)))

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

      case Brand.changeset(brand, brand_params, BN.current_user(conn), "Update")
           |> Repo.update() do
        {:ok, brand} ->
          conn
          |> put_flash(:info, "Brand logo updated successfully.")
          |> redirect(to: brand_path(conn, :index, BN.get_domain(conn)))

        {:error, %Ecto.Changeset{} = changeset} ->
          # render(conn, "edit.html", brand: brand, changeset: changeset)
          conn
          |> put_flash(:info, "Brand logo updated successfully.")
          |> redirect(to: brand_path(conn, :index, BN.get_domain(conn)))
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
