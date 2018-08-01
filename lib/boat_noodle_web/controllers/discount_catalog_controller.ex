defmodule BoatNoodleWeb.DiscountCatalogController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.DiscountCatalog
  alias BoatNoodle.BN.DiscountItem

  def index(conn, _params) do
    discount_catalog = Repo.all(DiscountCatalog)
    discounts = Repo.all(Discount)
    discounts_items = Repo.all(DiscountItem)

    render(
      conn,
      "index.html",
      discounts_items: discounts_items,
      discounts: discounts,
      discount_catalog: discount_catalog
    )
  end

  def discount_discounts_items(conn, _params) do
    discount_catalog = Repo.all(DiscountCatalog)
    discounts = Repo.all(Discount)
    discounts_items = Repo.all(DiscountItem)

    render(
      conn,
      "discount_discounts_items.html",
      discounts_items: discounts_items,
      discounts: discounts,
      discount_catalog: discount_catalog
    )
  end

  def new(conn, _params) do
    changeset = BN.change_discount_catalog(%DiscountCatalog{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"discount_catalog" => discount_catalog_params}) do
    case BN.create_discount_catalog(discount_catalog_params) do
      {:ok, discount_catalog} ->
        conn
        |> put_flash(:info, "Discount catalog created successfully.")
        |> redirect(to: discount_catalog_path(conn, :show, discount_catalog))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def discount_remove_from_catalog(conn, %{
        "brand" => brand,
        "subcat_id" => subcat_id,
        "tag_id" => catalog_id
      }) do
    cata = Repo.get_by(DiscountCatalog, id: subcat_id, brand_id: BN.get_brand_id(conn))

    items =
      cata.categories |> String.split(",") |> Enum.sort() |> Enum.reject(fn x -> x == "" end)

    if Enum.any?(items, fn x -> x == catalog_id end) do
      items = List.delete(items, catalog_id) |> Enum.sort() |> Enum.join(",")
      DiscountCatalog.changeset(cata, %{categories: items}, BN.current_user(conn),"Insert") |> Repo.update()
    end

    send_resp(conn, 200, "ok")
  end

  def discount_insert_into_catalog(conn, %{
        "brand" => brand,
        "subcat_id" => subcat_id,
        "tag_id" => catalog_id
      }) do

    cata = Repo.get_by(DiscountCatalog, id: subcat_id, brand_id: BN.get_brand_id(conn))

    items =
      cata.categories |> String.split(",") |> Enum.sort() |> Enum.reject(fn x -> x == "" end)

    unless Enum.any?(items, fn x -> x == catalog_id end) do
      items = List.insert_at(items, 0, catalog_id) |> Enum.sort() |> Enum.join(",")
      DiscountCatalog.changeset(cata, %{categories: items}, BN.current_user(conn),"Insert") |> Repo.update()
    end

    send_resp(conn, 200, "ok")
  end

  def list_discount_catalog(conn, %{"brand" => brand, "subcatid" => subcat_id}) do

    disc_cata = Repo.get_by(DiscountCatalog, id: subcat_id, brand_id: BN.get_brand_id(conn))
    categories = disc_cata.categories |> String.split(",") |> Enum.sort()

    all_cata = Repo.all(from(d in Discount, select: %{id: d.discountid, name: d.discname}))

    disc_cat =
      Repo.all(
        from(
          d in Discount,
          where: d.discountid in ^categories,
          select: %{id: d.discountid, name: d.discname}
        )
      )

    not_selected = all_cata -- disc_cat

    json = %{selected: disc_cat, not_selected: not_selected} |> Poison.encode!()
    send_resp(conn, 200, json)
  end

   def list_discount_catalog3(conn, %{"brand" => brand, "subcatid" => subcat_id}) do
   
    catalogs_ori =
      Repo.all(
        from(m in DiscountCatalog, select: %{id: m.id, name: m.name, categories: m.categories})
      )
      |> Enum.map(fn x -> Map.put(x, :categories, String.split(x.categories, ",")) end)

    catalogs =
      for catalog <- catalogs_ori do
        if Enum.any?(catalog.categories, fn x -> x == subcat_id end) do
          catalog
        else
          nil
        end
      end
      |> Enum.reject(fn x -> x == nil end)
      |> Enum.map(fn x -> %{id: x.id, name: x.name} end)

    all_cata = catalogs_ori |> Enum.map(fn x -> %{id: x.id, name: x.name} end)
    not_selected = all_cata -- catalogs

    json = %{selected: catalogs, not_selected: not_selected} |> Poison.encode!()
    send_resp(conn, 200, json)
  end

   def discount_remove_from_catalog3(conn, %{"brand" => brand,"subcat_id" => subcat_id,"tag_id" => catalog_id}) do
          cata = Repo.get_by(DiscountCatalog, id: catalog_id, brand_id: BN.get_brand_id(conn))
          items = cata.categories |> String.split(",") |> Enum.sort() |> Enum.reject(fn x -> x == "" end)

          if Enum.any?(items, fn x -> x == subcat_id end) do
            items = List.delete(items, subcat_id) |> Enum.sort() |> Enum.join(",")
            DiscountCatalog.changeset(cata, %{categories: items}, BN.current_user(conn),"Remove") |> Repo.update()
          end

    send_resp(conn, 200, "ok")
  end

   def discount_insert_into_catalog3(conn, %{
        "brand" => brand,
        "subcat_id" => subcat_id,
        "tag_id" => catalog_id
      }) do
    cata = Repo.get_by(DiscountCatalog, id: catalog_id, brand_id: BN.get_brand_id(conn))
    items = cata.categories |> String.split(",") |> Enum.sort() |> Enum.reject(fn x -> x == "" end)

    unless Enum.any?(items, fn x -> x == subcat_id end) do

      items = List.insert_at(items, 0, subcat_id) |> Enum.sort() |> Enum.join(",")


      DiscountCatalog.changeset(cata, %{categories: items}, BN.current_user(conn),"Insert") |> Repo.update()
    end

    send_resp(conn, 200, "ok")
  end

   def list_discount_catalog4(conn, %{"brand" => brand, "subcatid" => subcat_id}) do
   
    catalogs_ori =
      Repo.all(
        from(m in DiscountCatalog, select: %{id: m.id, name: m.name, discounts: m.discounts})
      )
      |> Enum.map(fn x -> Map.put(x, :discounts, String.split(x.discounts, ",")) end)

    catalogs =
      for catalog <- catalogs_ori do
        if Enum.any?(catalog.discounts, fn x -> x == subcat_id end) do
          catalog
        else
          nil
        end
      end
      |> Enum.reject(fn x -> x == nil end)
      |> Enum.map(fn x -> %{id: x.id, name: x.name} end)

    all_cata = catalogs_ori |> Enum.map(fn x -> %{id: x.id, name: x.name} end)
    not_selected = all_cata -- catalogs

    json = %{selected: catalogs, not_selected: not_selected} |> Poison.encode!()
    send_resp(conn, 200, json)
  end

   def discount_remove_from_catalog4(conn, %{"brand" => brand,"subcat_id" => subcat_id,"tag_id" => catalog_id}) do
          cata = Repo.get_by(DiscountCatalog, id: catalog_id, brand_id: BN.get_brand_id(conn))
          items = cata.discounts |> String.split(",") |> Enum.sort() |> Enum.reject(fn x -> x == "" end)

          if Enum.any?(items, fn x -> x == subcat_id end) do
         
            items = List.delete(items, subcat_id) |> Enum.sort() |> Enum.join(",")
            DiscountCatalog.changeset(cata, %{discounts: items},BN.current_user(conn),"Insert") |> Repo.update()
          end

    send_resp(conn, 200, "ok")
  end

   def discount_insert_into_catalog4(conn, %{
        "brand" => brand,
        "subcat_id" => subcat_id,
        "tag_id" => catalog_id
      }) do
    cata = Repo.get_by(DiscountCatalog, id: catalog_id, brand_id: BN.get_brand_id(conn))
    items = cata.discounts |> String.split(",") |> Enum.sort() |> Enum.reject(fn x -> x == "" end)

    unless Enum.any?(items, fn x -> x == subcat_id end) do

      items = List.insert_at(items, 0, subcat_id) |> Enum.sort() |> Enum.join(",")
      DiscountCatalog.changeset(cata, %{discounts: items},BN.current_user(conn),"Insert") |> Repo.update()
    end

    send_resp(conn, 200, "ok")
  end


  def discount_remove_from_catalog2(conn, %{"brand" => brand,"subcat_id" => subcat_id,"tag_id" => catalog_id}) do
          cata = Repo.get_by(DiscountCatalog, id: subcat_id, brand_id: BN.get_brand_id(conn))
          items = cata.discounts |> String.split(",") |> Enum.sort() |> Enum.reject(fn x -> x == "" end)

          if Enum.any?(items, fn x -> x == catalog_id end) do
            # insert...
            items = List.delete(items, catalog_id) |> Enum.sort() |> Enum.join(",")
            DiscountCatalog.changeset(cata, %{discounts: items}, BN.current_user(conn),"Remove") |> Repo.update()
          end

    send_resp(conn, 200, "ok")
  end

  def discount_insert_into_catalog2(conn, %{
        "brand" => brand,
        "subcat_id" => subcat_id,
        "tag_id" => catalog_id
      }) do
    cata = Repo.get_by(DiscountCatalog, id: subcat_id, brand_id: BN.get_brand_id(conn))
    items = cata.discounts |> String.split(",") |> Enum.sort() |> Enum.reject(fn x -> x == "" end)

    unless Enum.any?(items, fn x -> x == catalog_id end) do

      items = List.insert_at(items, 0, catalog_id) |> Enum.sort() |> Enum.join(",")
      DiscountCatalog.changeset(cata, %{discounts: items}, BN.current_user(conn),"Insert") |> Repo.update()
    end

    send_resp(conn, 200, "ok")
  end

  def list_discount_catalog2(conn, %{"brand" => brand, "subcatid" => subcat_id}) do

      disc_cata = Repo.get_by(DiscountCatalog, id: subcat_id, brand_id: BN.get_brand_id(conn))
    discounts = disc_cata.discounts |> String.split(",") |> Enum.sort()

    all_cata = Repo.all(from(d in DiscountItem, select: %{id: d.discountitemsid, name: d.discitemsname}))

    disc_cat =
      Repo.all(
        from(
          d in DiscountItem,
          where: d.discountitemsid in ^discounts,
          select: %{id: d.discountitemsid, name: d.discitemsname}
        )
      )

    not_selected = all_cata -- disc_cat

    json = %{selected: disc_cat, not_selected: not_selected} |> Poison.encode!()
    send_resp(conn, 200, json)
  end

  def show(conn, %{"id" => id}) do
    discount_catalog = BN.get_discount_catalog!(id)
    render(conn, "show.html", discount_catalog: discount_catalog)
  end

  def edit(conn, %{"id" => id}) do
    discount_catalog = BN.get_discount_catalog!(id)
    changeset = BN.change_discount_catalog(discount_catalog)
    render(conn, "edit.html", discount_catalog: discount_catalog, changeset: changeset)
  end

  def update(conn, %{"id" => id, "discount_catalog" => discount_catalog_params}) do
    discount_catalog = BN.get_discount_catalog!(id)

    case BN.update_discount_catalog(discount_catalog, discount_catalog_params) do
      {:ok, discount_catalog} ->
        conn
        |> put_flash(:info, "Discount catalog updated successfully.")
        |> redirect(to: discount_catalog_path(conn, :show, discount_catalog))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", discount_catalog: discount_catalog, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    discount_catalog = BN.get_discount_catalog!(id)
    {:ok, _discount_catalog} = BN.delete_discount_catalog(discount_catalog)

    conn
    |> put_flash(:info, "Discount catalog deleted successfully.")
    |> redirect(to: discount_catalog_path(conn, :index, BN.get_domain(conn)))
  end
end
