defmodule BoatNoodleWeb.SubcatCatalogController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.SubcatCatalog
  require IEx

  def index(conn, _params) do
    subcat_catalog = BN.list_subcat_catalog()
    render(conn, "index.html", subcat_catalog: subcat_catalog)
  end

  def new(conn, _params) do
    changeset = BN.change_subcat_catalog(%SubcatCatalog{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"subcat_catalog" => subcat_catalog_params}) do
    case BN.create_subcat_catalog(subcat_catalog_params) do
      {:ok, subcat_catalog} ->
        conn
        |> put_flash(:info, "Subcat catalog created successfully.")
        |> redirect(to: subcat_catalog_path(conn, :show, subcat_catalog))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    subcat_catalog = BN.get_subcat_catalog!(id)
    render(conn, "show.html", subcat_catalog: subcat_catalog)
  end

  def edit(conn, %{"id" => id}) do
    subcat_catalog = BN.get_subcat_catalog!(id)

    menu_catalog =
      Repo.all(
        from(
          m in BoatNoodle.BN.MenuCatalog,
          where: m.brand_id == ^BN.get_brand_id(conn),
          select: %{catalog_id: m.id, name: m.name}
        )
      )

    price_list_catalog =
      Repo.all(
        from(
          s in BoatNoodle.BN.SubcatCatalog,
          left_join: r in BoatNoodle.BN.MenuCatalog,
          on: s.catalog_id == r.id,
          where:
            s.subcat_id == ^subcat_catalog.subcat_id and s.is_combo != 1 and
              r.brand_id == ^BN.get_brand_id(conn),
          select: %{catalog_id: s.catalog_id, name: r.name}
        )
      )

    balence = menu_catalog -- price_list_catalog

    active =
      for item <- price_list_catalog do
        %{catalog_id: item.catalog_id, name: item.name, is_active: 1}
      end

    not_active =
      for item <- balence do
        %{catalog_id: item.catalog_id, name: item.name, is_active: 0}
      end

    all = active ++ not_active

    changeset = BN.change_subcat_catalog(subcat_catalog)

    render(conn, "edit.html",
      menu_catalog: menu_catalog,
      subcat_catalog: subcat_catalog,
      all: all,
      changeset: changeset
    )
  end

  def update(conn, %{"id" => id, "subcat_catalog" => subcat_catalog_params}) do
    IEx.pry()
    subcat_catalog = BN.get_subcat_catalog!(id)

    is_active =
      if subcat_catalog_params["is_active"] == "true" do
        1
      else
        0
      end

    subcat_catalog_params = Map.put(subcat_catalog_params, "is_active", is_active)

    case BN.update_subcat_catalog(subcat_catalog, subcat_catalog_params) do
      {:ok, subcat_catalog} ->
        conn
        |> put_flash(:info, "Price List updated successfully.")
        |> redirect(to: menu_item_path(conn, :index, BN.get_domain(conn)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", subcat_catalog: subcat_catalog, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    subcat_catalog = BN.get_subcat_catalog!(id)
    {:ok, _subcat_catalog} = BN.delete_subcat_catalog(subcat_catalog)

    conn
    |> put_flash(:info, "Subcat catalog deleted successfully.")
  end
end
