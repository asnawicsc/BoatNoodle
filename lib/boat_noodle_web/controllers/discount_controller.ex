defmodule BoatNoodleWeb.DiscountController do
  use BoatNoodleWeb, :controller
  require IEx
  alias BoatNoodle.BN
  alias BoatNoodle.BN.Discount
  alias BoatNoodle.BN.DiscountItem
  alias BoatNoodle.BN.ItemCat
  alias BoatNoodle.BN.DiscountType
  alias BoatNoodle.BN.ItemSubcat

  def index(conn, _params) do
    discount = BN.list_discount()
    brand = BN.get_brand_id(conn)

    discount_details =
      Repo.all(
        from(
          s in Discount,
          where: s.brand_id == ^brand,
          select: %{
            discountid: s.discountid,
            discount_name: s.discname,
            discount_description: s.descriptions,
            activate: s.is_visable
          }
        )
      )

    discount_items =
      Repo.all(
        from(
          s in DiscountItem,
          where: s.brand_id == ^brand,
          select: %{
            discountitemsid: s.discountitemsid,
            discitemsname: s.discitemsname,
            description: s.descriptions,
            discamtpercentage: s.discamtpercentage,
            activate: s.is_visable
          }
        )
      )
      |> Enum.uniq()

    discount_catalog =
      Repo.all(
        from(
          s in DiscountCatalog,
          where: s.brand_id == ^brand,
          select: %{
            id: s.id,
            name: s.name
          }
        )
      )

    render(
      conn,
      "index.html",
      discount_catalog: discount_catalog,
      discount_items: discount_items,
      discount_details: discount_details,
      discount: discount
    )
  end

  def export(conn, _params) do
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"Discount Item List.csv\"")
    |> send_resp(200, csv_content(conn, _params))
  end

  defp csv_content(conn, _params) do
    brand = Repo.get_by(Brand, domain_name: _params["brand"])

    all =
      Repo.all(
        from(
          s in DiscountItem,
          left_join: d in Discount,
          where: d.discountid == s.discountid and s.brand_id == ^brand.id,
          select: %{
            discitemsname: s.discitemsname,
            target_cat: s.target_cat,
            discname: d.discname,
            is_targetmenuitems: s.is_targetmenuitems,
            multi_item_list: s.multi_item_list,
            discountid: s.discountid,
            descriptions: s.descriptions,
            discamtpercentage: s.discamtpercentage,
            disctype: s.disctype,
            disc_qty: s.disc_qty,
            is_visable: s.is_visable
          }
        )
      )

    csv_content = [
      'Discount Name',
      'Discount Category',
      'Descriptions',
      'Discount Amount/Percentage',
      'Discount Type',
      'Discount Qty',
      'Target Menu Category',
      'Target Menu Item',
      'Activated?'
    ]

    data =
      for item <- all do
        cat_name =
          if item.target_cat != 0 do
            item.target_cat
          else
            0
          end

        is_visable =
          if item.is_visable != 0 do
            "YES"
          else
            "NO"
          end

        is_targetmenuitems = item.is_targetmenuitems

        item_name =
          if is_targetmenuitems != 0 do
            is_targetmenuitems
          else
            item.multi_item_list
          end

        [
          item.discitemsname,
          item.discname,
          item.descriptions,
          item.discamtpercentage,
          item.disctype,
          item.disc_qty,
          cat_name,
          item_name,
          is_visable
        ]
      end

    csv_content =
      List.insert_at(data, 0, csv_content)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string
  end

  def discount_category_new(conn, params) do
    discount_catalog =
      Repo.all(
        from(
          m in BoatNoodle.BN.DiscountCatalog,
          where: m.brand_id == ^BN.get_brand_id(conn),
          select: %{id: m.id, name: m.name}
        )
      )

    discount =
      Repo.all(
        from(
          s in BoatNoodle.BN.Discount,
          where: s.brand_id == ^BN.get_brand_id(conn),
          select: %{id: s.discountid, name: s.discname}
        )
      )

    render(
      conn,
      "discount_category_new.html",
      discount: discount,
      discount_catalog: discount_catalog
    )
  end

  def create_discount_category_new(conn, params) do
    item = params["item"]
    discname = item["discount_name"]

    discamtpercentage =
      if item["amount_percentage"] == "" do
        0
      else
        item["amount_percentage"]
      end

    {disctype, is_categorize} =
      if item["select"] == "1" do
        disctype = "CASH"
        is_categorize = 0
        {disctype, is_categorize}
      else
        disctype = "FREE"
        is_categorize = 1
        {disctype, is_categorize}
      end

    descriptions = item["description"]

    is_visable =
      if item["status"] == "on" do
        1
      else
        0
      end

    discountid =
      Repo.all(from(c in Discount, select: %{discountid: c.discountid}))
      |> Enum.map(fn x -> Integer.to_string(x.discountid) end)
      |> List.last()

    new_discount_id = String.to_integer(discountid) + 1

    cat_params = %{
      disctype: disctype,
      is_categorize: is_categorize,
      discname: discname,
      discamtpercentage: discamtpercentage,
      descriptions: descriptions,
      is_visable: is_visable,
      target_cat: 0,
      brand_id: BN.get_brand_id(conn)
    }

    discount =
      BoatNoodle.BN.Discount.changeset(
        %BoatNoodle.BN.Discount{},
        cat_params,
        BN.current_user(conn),
        "Create"
      )

    BoatNoodle.Repo.insert(discount)

    discount =
      Repo.get_by(
        Discount,
        discname: discname,
        discamtpercentage: discamtpercentage,
        is_visable: is_visable
      )

    branch_ids = params["branc"]["branch"] |> String.split(",")

    for id <- branch_ids do
      id = id |> String.to_integer()
      branch = Repo.get_by(DiscountCatalog, id: id, brand_id: BN.get_brand_id(conn))
      dis_categories = branch.categories
      disc_cat = dis_categories |> String.split(",")

      disc_id = discount.discountid |> Integer.to_string()
      all_discount_categories = List.insert_at(disc_cat, 0, disc_id)
      new_categories = all_discount_categories |> Enum.join(",")

      discount_catalog_params = %{categories: new_categories}

      discount_catalog =
        BoatNoodle.BN.DiscountCatalog.changeset(
          branch,
          discount_catalog_params,
          BN.current_user(conn),
          "Update"
        )

      BoatNoodle.Repo.insert(discount_catalog)
    end

    conn
    |> put_flash(:info, "Discount Category created successfully.")
    |> redirect(to: discount_path(conn, :index, BN.get_domain(conn)))
  end

  def discount_catalog_new(conn, params) do
    discount =
      Repo.all(
        from(
          m in BoatNoodle.BN.Discount,
          where: m.brand_id == ^BN.get_brand_id(conn) and m.is_visable == ^1,
          select: %{discountid: m.discountid, discname: m.discname}
        )
      )

    discount_items =
      Repo.all(
        from(
          m in BoatNoodle.BN.DiscountItem,
          left_join: d in BoatNoodle.BN.Discount,
          where: d.discountid == m.discountid and d.brand_id == ^BN.get_brand_id(conn),
          select: %{
            discname: d.discname,
            discountitemsid: m.discountid,
            discitemname: m.discitemsname
          }
        )
      )

    render(
      conn,
      "discount_catalog_new.html",
      discount: discount,
      discount_items: discount_items
    )
  end

  def create_discount_catalog_new(conn, params) do
    brand = BN.get_brand_id(conn)
    name = params["name"]
    categories = params["cat"]
    discounts = params["items"]

    discount_catalog_params = %{
      name: name,
      categories: categories,
      discounts: discounts,
      brand_id: brand
    }

    discount_catalog =
      BoatNoodle.BN.DiscountCatalog.changeset(
        %BoatNoodle.BN.DiscountCatalog{},
        discount_catalog_params,
        BN.current_user(conn),
        "Create"
      )

    BoatNoodle.Repo.insert(discount_catalog)

    conn
    |> put_flash(:info, "Discount Catalog created successfully.")
    |> redirect(to: discount_path(conn, :index, BN.get_domain(conn)))
  end

  def discount_item_new(conn, params) do
    brand = BN.get_brand_id(conn)

    discount_catalog =
      Repo.all(
        from(
          m in BoatNoodle.BN.DiscountCatalog,
          where: m.brand_id == ^BN.get_brand_id(conn),
          select: %{id: m.id, name: m.name}
        )
      )

    discount =
      Repo.all(
        from(
          m in BoatNoodle.BN.Discount,
          where: m.brand_id == ^BN.get_brand_id(conn),
          select: %{discountid: m.discountid, discname: m.discname}
        )
      )

    discount_type = Repo.all(from(s in BoatNoodle.BN.DiscountType))

    item_subcat =
      Repo.all(
        from(
          b in BoatNoodle.BN.ItemSubcat,
          where: b.brand_id == ^brand,
          select: %{
            subcatid: b.subcatid,
            itemname: b.itemname,
            itemprice: b.itemprice,
            price_code: b.price_code
          }
        )
      )

    categories =
      Repo.all(
        from(
          s in BoatNoodle.BN.ItemCat,
          where: s.brand_id == ^brand,
          select: %{id: s.itemcatid, name: s.itemcatname}
        )
      )

    render(
      conn,
      "discount_item_new.html",
      discount_catalog: discount_catalog,
      item_subcat: item_subcat,
      categories: categories,
      discount: discount,
      discount_type: discount_type
    )
  end

  def create_discount_item_new(conn, params) do
    item = params["item"]

    discountid =
      if item["discount_category"] == "" do
        0
      else
        item["discount_category"] |> String.to_integer()
      end

    descriptions = item["description"]
    discamtpercentage = item["discount_amount"]
    discitemsname = item["discount_item"]
    discount_percentage = item["discount_percentage"]

    disc_qty = item["discount_quantity"]
    type = item["discount_type"] |> String.to_integer()
    all_disc_type = Repo.get_by(DiscountType, disctypeid: type)
    disc_type = all_disc_type.disctypename

    target_cat =
      if item["target_category"] == "" do
        0
      else
        item["target_category"] |> String.to_integer()
      end

    discamtpercentage =
      case type do
        1 ->
          item["discount_amount"]

        2 ->
          item["discount_percentage"]

        3 ->
          item["voucher_amount"]

        4 ->
          0

        5 ->
          0

        6 ->
          item["discount_percentage"]
      end

    {is_targetmenuitems, multi_item_list} =
      if item["target_items"] == "" do
        {is_targetmenuitems = 0, multi_item_list = ""}
      else
        count = item["target_items"] |> String.split(",") |> Enum.count()

        {is_targetmenuitems, multi_item_list} =
          if count > 1 do
            is_targetmenuitems = 0
            multi_item_list = item["target_items"]
            {is_targetmenuitems, multi_item_list}
          else
            multi_item_list = ""
            is_targetmenuitems = item["target_items"] |> String.to_integer()
            {is_targetmenuitems, multi_item_list}
          end
      end

    is_visable =
      if item["status"] == "on" do
        1
      else
        0
      end

    min_spend = item["minimum_spend"]

    discount_items_params = %{
      discountid: discountid,
      discitemsname: discitemsname,
      descriptions: descriptions,
      discamtpercentage: discamtpercentage,
      target_cat: target_cat,
      disc_qty: disc_qty,
      disctype: disc_type,
      multi_item_list: multi_item_list,
      is_targetmenuitems: is_targetmenuitems,
      is_visable: is_visable,
      min_spend: min_spend,
      brand_id: BN.get_brand_id(conn)
    }

    discount_item =
      BoatNoodle.BN.DiscountItem.changeset(
        %BoatNoodle.BN.DiscountItem{},
        discount_items_params,
        BN.current_user(conn),
        "Create"
      )

    BoatNoodle.Repo.insert(discount_item)

    discountitem =
      Repo.get_by(
        DiscountItem,
        discountid: discountid,
        discitemsname: discitemsname,
        descriptions: descriptions
      )

    branch_ids = params["branc"]["branch"] |> String.split(",")

    for id <- branch_ids do
      id = id |> String.to_integer()
      branch = Repo.get_by(DiscountCatalog, id: id, brand_id: BN.get_brand_id(conn))
      dis_discount = branch.discounts
      disc_discount = dis_discount |> String.split(",")

      disc_id = discountitem.discountitemsid |> Integer.to_string()
      all_discount_discounts = List.insert_at(disc_discount, 0, disc_id)
      new_discounts = all_discount_discounts |> Enum.join(",")

      params = %{discounts: new_discounts}

      changeset =
        BoatNoodle.BN.DiscountCatalog.changeset(branch, params, BN.current_user(conn), "Update")

      BoatNoodle.Repo.update(changeset)
    end

    conn
    |> put_flash(:info, "Discount Item  successfully created.")
    |> redirect(to: discount_path(conn, :index, BN.get_domain(conn)))
  end

  def discount_category_details(conn, %{"id" => id}) do
    # discount = BN.get_discount!(id)

    discount = Repo.get_by(Discount, brand_id: BN.get_brand_id(conn), discountid: id)

    render(
      conn,
      "discount_category_details.html",
      discount: discount,
      id: id
    )
  end

  def discount_item_details(conn, %{"id" => id}) do
    brand = BN.get_brand_id(conn)

    discount_catalog =
      Repo.all(
        from(
          m in BoatNoodle.BN.DiscountCatalog,
          where: m.brand_id == ^BN.get_brand_id(conn),
          select: %{id: m.id, name: m.name}
        )
      )

    discount =
      Repo.all(
        from(
          m in BoatNoodle.BN.Discount,
          where: m.brand_id == ^BN.get_brand_id(conn),
          select: %{discountid: m.discountid, discname: m.discname}
        )
      )

    discount_type = Repo.all(from(s in BoatNoodle.BN.DiscountType))

    item_subcat =
      Repo.all(
        from(
          b in BoatNoodle.BN.ItemSubcat,
          where: b.brand_id == ^BN.get_brand_id(conn),
          select: %{
            subcatid: b.subcatid,
            itemname: b.itemname,
            itemprice: b.itemprice,
            price_code: b.price_code
          }
        )
      )

    categories =
      Repo.all(
        from(
          s in BoatNoodle.BN.ItemCat,
          where: s.brand_id == ^brand,
          select: %{id: s.itemcatid, name: s.itemcatname}
        )
      )

    discount_items =
      Repo.get_by(BN.DiscountItem, brand_id: BN.get_brand_id(conn), discountitemsid: id)

    discount_a =
      Repo.all(
        from(
          s in DiscountItem,
          left_join: b in ItemCat,
          on: s.target_cat == b.itemcatid,
          left_join: c in DiscountType,
          on: s.disctype == c.disctypename,
          left_join: e in Discount,
          on: s.discountid == e.discountid,
          where:
            s.discountitemsid == ^discount_items.discountitemsid and
              s.brand_id == ^BN.get_brand_id(conn),
          select: %{
            descriptions: s.descriptions,
            disc_qty: s.disc_qty,
            discamtpercentage: s.discamtpercentage,
            discitemsname: s.discitemsname,
            discountid: s.discountid,
            discountitemsid: s.discountitemsid,
            disctype: s.disctype,
            is_categorize: s.is_categorize,
            is_targetmenuitems: s.is_targetmenuitems,
            multi_item_list: s.multi_item_list,
            is_visable: s.is_visable,
            min_spend: s.min_spend,
            target_cat: s.target_cat,
            itemcatname: b.itemcatname,
            disctypeid: c.disctypeid,
            discname: e.discname,
            brand_id: s.brand_id
          }
        )
      )
      |> hd

    render(
      conn,
      "discount_item_details.html",
      discount_catalog: discount_catalog,
      discount: discount,
      discount_type: discount_type,
      item_subcat: item_subcat,
      categories: categories,
      discount_items: discount_items,
      discount_items: discount_items,
      discount_a: discount_a
    )
  end

  def discount_catalog_details(conn, %{"id" => id}) do
    discount_catalog = Repo.get_by(DiscountCatalog, brand_id: BN.get_brand_id(conn), id: id)

    discounts = Repo.all(from(d in Discount, where: d.brand_id == ^BN.get_brand_id(conn)))

    all_discount_catalog =
      Repo.all(from(d in DiscountCatalog, where: d.brand_id == ^BN.get_brand_id(conn)))

    render(
      conn,
      "discount_catalog_details.html",
      discount_catalog: discount_catalog,
      discounts: discounts,
      all_discount_catalog: all_discount_catalog
    )
  end

  def edit_discount_catalog_detail(conn, params) do
    brand = BN.get_brand_id(conn)

    id = params["id"] |> String.to_integer()
    name = params["name"]
    discount_catalog = Repo.get_by(BoatNoodle.BN.DiscountCatalog, id: id, brand_id: brand)

    changeset =
      BoatNoodle.BN.DiscountCatalog.changeset(
        discount_catalog,
        %{name: name},
        BN.current_user(conn),
        "Update"
      )

    case BoatNoodle.Repo.update(changeset) do
      {:ok, discount_catalog} ->
        conn
        |> put_flash(:info, "Discount Catalog updated successfully.")
        |> redirect(to: discount_path(conn, :discount_catalog_details, BN.get_domain(conn), id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "discount_catalog_details.html",
          discount_catalog: discount_catalog,
          changeset: changeset
        )
    end
  end

  def edit_discount_category_detail(conn, params) do
    brand = BN.get_brand_id(conn)

    id = params["discountid"] |> String.to_integer()
    discname = params["name"]
    descriptions = params["descriptions"]
    discount_type = params["discount_type"] |> String.to_integer()

    {disc_type, discamtpercentage} =
      if discount_type == 1 do
        disc_type = "FREE"
        discamtpercentage = 0
        {disc_type, discamtpercentage}
      else
        disc_type = "CASH"
        discamtpercentage = params["discamtpercentage"]
        {disc_type, discamtpercentage}
      end

    is_visable =
      if params["is_visable"] == "on" do
        1
      else
        0
      end

    discount = Repo.get_by(BoatNoodle.BN.Discount, discountid: id, brand_id: brand)

    discount_category_params = %{
      is_categorize: discount_type,
      disctype: disc_type,
      discname: discname,
      descriptions: descriptions,
      discamtpercentage: discamtpercentage,
      is_visable: is_visable
    }

    changeset =
      BoatNoodle.BN.Discount.changeset(
        discount,
        discount_category_params,
        BN.current_user(conn),
        "Update"
      )

    case BoatNoodle.Repo.update(changeset) do
      {:ok, discount} ->
        conn
        |> put_flash(:info, "Discount Category updated successfully.")
        |> redirect(to: discount_path(conn, :discount_category_details, BN.get_domain(conn), id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "discount_category_details.html", discount: discount, changeset: changeset)
    end
  end

  def edit_discount_item_details(conn, params) do
    brand = BN.get_brand_id(conn)

    descriptions = params["descriptions"]
    disc_qty = params["disc_qty"] |> String.to_integer()
    discamtpercentage = params["discamtpercentage"]
    discitemsname = params["discitemsname"]
    discount_amount = params["discount_amount"]
    discountid = params["discountid"] |> String.to_integer()
    discountitemsid = params["discountitemsid"]
    disctype = params["disctype"] |> String.to_integer()
    is_targetmenuitems = params["is_targetmenuitems"]
    min_spend = params["min_spend"]
    target_cat = params["target_cat"] |> String.to_integer()
    voucher_amount = params["voucher_amount"]

    is_visable =
      if params["is_visable"] == "on" do
        1
      else
        0
      end

    {is_targetmenuitems, multi_item_list} =
      if params["is_targetmenuitems"] == nil do
        is_targetmenuitems = 0
        multi_item_list = ""
        {is_targetmenuitems, multi_item_list}
      else
        count = params["is_targetmenuitems"] |> Enum.count()

        {is_targetmenuitems, multi_item_list} =
          if count > 1 do
            is_targetmenuitems = 0
            multi_item_list = params["is_targetmenuitems"] |> Enum.join(",")
            {is_targetmenuitems, multi_item_list}
          else
            multi_item_list = ""
            is_targetmenuitems = params["is_targetmenuitems"] |> hd |> String.to_integer()
            {is_targetmenuitems, multi_item_list}
          end
      end

    discount_type = Repo.get_by(BoatNoodle.BN.DiscountType, disctypeid: disctype)
    disctype = discount_type.disctypename

    discount_item =
      Repo.get_by(BoatNoodle.BN.DiscountItem, discountitemsid: discountitemsid, brand_id: brand)

    discount_item_params = %{
      descriptions: descriptions,
      disc_qty: disc_qty,
      descriptions: descriptions,
      discamtpercentage: discamtpercentage,
      discitemsname: discitemsname,
      discountid: discountid,
      discountitemsid: discountitemsid,
      disctype: disctype,
      is_targetmenuitems: is_targetmenuitems,
      target_cat: target_cat,
      multi_item_list: multi_item_list,
      is_visable: is_visable,
      min_spend: min_spend
    }

    changeset =
      BoatNoodle.BN.DiscountItem.changeset(
        discount_item,
        discount_item_params,
        BN.current_user(conn),
        "Update"
      )

    case BoatNoodle.Repo.update(changeset) do
      {:ok, discount_item} ->
        conn
        |> put_flash(:info, "Discount Item updated successfully.")
        |> redirect(
          to: discount_path(conn, :discount_item_details, BN.get_domain(conn), discountitemsid)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "discount_item_details.html",
          discount_item: discount_item,
          changeset: changeset
        )
    end
  end

  def discount_catalog_copy(conn, %{"id" => id}) do
    brand = BN.get_brand_id(conn)

    id = id |> String.to_integer()
    discount_catalog = Repo.get_by(BoatNoodle.BN.DiscountCatalog, id: id, brand_id: brand)

    render(conn, "discount_catalog_copy.html", discount_catalog: discount_catalog)
  end

  def create_discount_catalog_copy(conn, params) do
    categories = params["categories"]
    discounts = params["discounts"]
    name = params["name"]

    copy_params = %{categories: categories, discounts: discounts, name: name}

    discount =
      BoatNoodle.BN.DiscountCatalog.changeset(
        %BoatNoodle.BN.DiscountCatalog{},
        copy_params,
        BN.current_user(conn),
        "Copy Discount Catalog"
      )

    BoatNoodle.Repo.insert(discount)

    case BoatNoodle.Repo.insert(discount) do
      {:ok, discount_catalg} ->
        conn
        |> put_flash(:info, "Discount Catalog Successfully Copy")
        |> redirect(to: discount_path(conn, :index, BN.get_domain(conn)))
    end
  end

  def new(conn, _params) do
    changeset = BN.change_discount(%Discount{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"discount" => discount_params}) do
    case BN.create_discount(discount_params) do
      {:ok, discount} ->
        conn
        |> put_flash(:info, "Discount created successfully.")
        |> redirect(to: discount_path(conn, :show, discount))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    discount = BN.get_discount!(id)
    render(conn, "show.html", discount: discount)
  end

  def edit(conn, %{"id" => id}) do
    discount = BN.get_discount!(id)
    changeset = BN.change_discount(discount)
    render(conn, "edit.html", discount: discount, changeset: changeset)
  end

  def update(conn, %{"id" => id, "discount" => discount_params}) do
    discount = BN.get_discount!(id)

    case BN.update_discount(discount, discount_params) do
      {:ok, discount} ->
        conn
        |> put_flash(:info, "Discount updated successfully.")
        |> redirect(to: discount_path(conn, :show, discount))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", discount: discount, changeset: changeset)
    end
  end

  def upload_voucher(conn, params) do
    discountid = params["disc_cat"] |> String.to_integer()
    file = params["item_subcat"]["file"]

    {:ok, binary} = File.read(params["item_subcat"]["file"].path)

    voucher_codes = binary |> String.split("\r\n")

    disc_cat =
      Repo.get_by(Discount, discountid: params["disc_cat"], brand_id: BN.get_brand_id(conn))

    name = disc_cat.discname

    for voucher_code <- voucher_codes do
      Voucher.changeset(%Voucher{}, %{code_number: voucher_code, discount_name: name})
      |> Repo.insert()
    end

    conn
    |> put_flash(:info, "Discount updated successfully.")
    |> redirect(to: discount_path(conn, :index, BN.get_domain(conn)))
  end

  def delete(conn, %{"id" => id}) do
    discount = BN.get_discount!(id)
    {:ok, _discount} = BN.delete_discount(discount)

    conn
    |> put_flash(:info, "Discount deleted successfully.")
    |> redirect(to: discount_path(conn, :index, BN.get_domain(conn)))
  end
end
