defmodule BoatNoodleWeb.BranchController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.{Branch, Organization, User, TagCatalog, Tag, TagItems}
  alias BoatNoodle.BN.{MenuItem, MenuCatalog, ItemSubcat, ItemCat, ComboDetails, PaymentType}
  require IEx

  def printers(conn, %{"id" => id}) do
    printers =
      Repo.all(from(t in Tag, where: t.branch_id == ^id and t.brand_id == ^BN.get_brand_id(conn)))

    branch =
      Repo.all(
        from(b in Branch, where: b.branchid == ^id and b.brand_id == ^BN.get_brand_id(conn))
      )
      |> hd()

    menu_cat =
      Repo.all(
        from(
          m in MenuCatalog,
          where: m.id == ^branch.menu_catalog and m.brand_id == ^BN.get_brand_id(conn)
        )
      )
      |> hd()

    item_ids = menu_cat.items |> String.split(",") |> Enum.reject(fn x -> x == "" end)

    subcats_data =
      Repo.all(
        from(
          s in ItemSubcat,
          where:
            s.subcatid in ^item_ids and s.brand_id == ^BN.get_brand_id(conn) and
              s.is_activate == ^1,
          select: %{
            id: s.subcatid,
            name: s.itemname,
            code: s.itemcode
          },
          order_by: [asc: s.itemcode]
        )
      )

    subcats =
      subcats_data
      |> Enum.reject(fn x -> String.length(Integer.to_string(x.id)) >= 6 end)

    changeset = Tag.changeset(%BoatNoodle.BN.Tag{}, %{}, BN.current_user(conn), "new")

    html =
      Phoenix.View.render_to_string(
        BoatNoodleWeb.TagView,
        "subcat_checkbox.html",
        subcats: subcats
      )

    # need a list of combos
    # subcatid thats 6 digit are combos
    combos = subcats_data |> Enum.filter(fn x -> String.length(Integer.to_string(x.id)) == 6 end)
    combo_ids = combos |> Enum.map(fn x -> x.id end)

    combo_items =
      Repo.all(from(c in ComboDetails, where: c.combo_id in ^combo_ids))
      |> Enum.group_by(fn x -> x.combo_id end)

    # each combo has a list of items
    # there are 2 type of combos but both also go into this combo_item_ids column
    # allow user to set which item goes to which printer

    render(
      conn,
      "printers.html",
      branch: branch,
      printers: printers,
      subcats: subcats,
      changeset: changeset,
      html: html,
      combos: combos,
      combo_items: combo_items
    )
  end

  def populate_printers(conn, %{"id" => id}) do
    branch = Repo.get_by(Branch, branchid: id, brand_id: BN.get_brand_id(conn))

    menu_catalog =
      Repo.get_by(MenuCatalog, id: branch.menu_catalog, brand_id: BN.get_brand_id(conn))

    # check the item subcats from menu catalog
    item_subcats = menu_catalog.items |> String.split(",") |> Enum.reject(fn x -> x == "" end)

    subcat_printer =
      for item_subcat <- item_subcats do
        item_subcat_id = item_subcat

        item_subcat =
          Repo.get_by(ItemSubcat, subcatid: item_subcat_id, brand_id: BN.get_brand_id(conn))

        %{
          subcat_id: item_subcat.subcatid,
          printer: item_subcat.printer,
          tagdesc: item_subcat.tagdesc
        }
      end
      |> Enum.reject(fn x -> x.printer == nil end)

    for tag <- subcat_printer do
      old_tag =
        Repo.get_by(
          Tag,
          tagdesc: tag.tagdesc,
          printer: tag.printer,
          branch_id: id,
          brand_id: BN.get_brand_id(conn)
        )

      new_tag_id = Repo.all(from(t in Tag, select: t.tagid, order_by: [desc: t.tagid])) |> hd()

      if old_tag == nil do
        tag_id = new_tag_id + 1

        {:ok, old_tag} =
          Tag.changeset(
            %Tag{},
            %{
              tagid: tag_id,
              tagname: branch.branchcode <> " " <> tag.tagdesc,
              tagdesc: tag.tagdesc,
              printer: tag.printer,
              branch_id: id,
              brand_id: BN.get_brand_id(conn)
            },
            0,
            "new"
          )
          |> Repo.insert()
      end

      old_ids =
        if old_tag.subcat_ids == nil do
          ""
        else
          old_tag.subcat_ids
        end

      ids = old_ids |> String.split(",")
      ids = List.insert_at(ids, 0, tag.subcat_id)
      new_ids = Enum.join(ids, ",") |> String.trim_trailing(",")
      Tag.changeset(old_tag, %{subcat_ids: new_ids}, 0, "Update") |> Repo.update()
    end

    # check the combo items from menu catalog
    combo_items =
      menu_catalog.combo_items |> String.split(",") |> Enum.reject(fn x -> x == "" end)

    combo_printer =
      for combo_item <- combo_items do
        combo = Repo.get_by(ComboDetails, id: combo_item, brand_id: BN.get_brand_id(conn))

        if combo != nil do
          subcat_id =
            String.split(Integer.to_string(combo.combo_item_id), "") --
              String.split(Integer.to_string(combo.combo_id), "")

          item_subcat_id = subcat_id |> Enum.join() |> String.to_integer()

          item_subcat =
            Repo.get_by(ItemSubcat, subcatid: item_subcat_id, brand_id: BN.get_brand_id(conn))

          %{
            combo_item_id: combo.combo_item_id,
            printer: item_subcat.printer,
            tagdesc: item_subcat.tagdesc
          }
        end
      end
      |> Enum.reject(fn x -> x == nil end)
      |> Enum.reject(fn x -> x.printer == nil end)

    for tag <- combo_printer do
      old_tag =
        Repo.get_by(
          Tag,
          tagdesc: tag.tagdesc,
          printer: tag.printer,
          branch_id: id,
          brand_id: BN.get_brand_id(conn)
        )

      new_tag_id = Repo.all(from(t in Tag, select: t.tagid, order_by: [desc: t.tagid])) |> hd()

      if old_tag == nil do
        tag_id = new_tag_id + 1

        {:ok, old_tag} =
          Tag.changeset(
            %Tag{},
            %{
              tagid: tag_id,
              tagname: branch.branchcode <> " " <> tag.tagdesc,
              tagdesc: tag.tagdesc,
              printer: tag.printer,
              branch_id: id,
              brand_id: BN.get_brand_id(conn)
            },
            0,
            "new"
          )
          |> Repo.insert()
      end

      old_ids =
        if old_tag.combo_item_ids == nil do
          ""
        else
          old_tag.combo_item_ids
        end

      ids = old_ids |> String.split(",")
      ids = List.insert_at(ids, 0, tag.combo_item_id)
      new_ids = Enum.join(ids, ",") |> String.trim_trailing(",")
      Tag.changeset(old_tag, %{combo_item_ids: new_ids}, 0, "Update") |> Repo.update()
    end

    conn
    |> put_flash(:info, "Successfully populated")
    |> redirect(to: branch_path(conn, :index, BN.get_domain(conn)))
  end

  # def get_api(conn, %{"brand" => brand, "id" => branch_id}) do
  #   branch = Repo.get_by(Branch, branchid: branch_id, brand_id: BN.get_brand_id(conn))

  #   api_key =
  #     Comeonin.Bcrypt.hashpwsalt(branch.branchname) |> String.replace("$2b", "$2y")
  #     |> Base.url_encode64()

  #   cg = Branch.changeset(branch, %{api_key: api_key}, BN.current_user(conn), "Update")
  #   map = %{key: api_key} |> Poison.encode!()

  #   case Repo.update(cg) do
  #     {:ok, bb} ->
  #       send_resp(conn, 200, map)

  #     {:error, cg} ->
  #       send_resp(conn, 500, " not ok")
  #   end
  # end

  def get_api2(conn, %{"code" => branch_code}) do
    branch = Repo.get_by(Branch, branchcode: branch_code)

    api_key =
      Comeonin.Bcrypt.hashpwsalt(branch.branchname)
      |> String.replace("$2b", "$2y")
      |> Base.url_encode64()

    cg = Branch.changeset(branch, %{api_key: api_key}, 0, "edit")

    map = %{key: api_key} |> Poison.encode!()

    case Repo.update(cg) do
      {:ok, bb} ->
        send_resp(conn, 200, map)

      {:error, cg} ->
        send_resp(conn, 500, " not ok")
    end
  end

  def index(conn, params) do
    branch =
      Repo.all(
        from(
          b in Branch,
          left_join: o in Organization,
          on: b.org_id == o.organisationid,
          left_join: u in User,
          on: u.id == b.manager,
          where: b.brand_id == ^BN.get_brand_id(conn),
          select: %{
            branchid: b.branchid,
            branchname: b.branchname,
            branchcode: b.branchcode,
            b_address: b.b_address,
            org_id: o.organisationname,
            manager: u.username,
            num_staff: b.num_staff,
            sync_status: b.sync_status
          }
        )
      )
      |> Enum.reject(fn x -> x.branchcode == "ALL" end)

    branchids = branch |> Enum.map(fn x -> x.branchid end)
    tags = Repo.all(from(t in Tag, where: t.branch_id in ^branchids))

    tag_ids = tags |> Enum.group_by(fn x -> x.branch_id end) |> Map.keys()
    render(conn, "index.html", branch: branch, tag_ids: tag_ids)
  end

  def new(conn, _params) do
    changeset = Branch.changeset(%BoatNoodle.BN.Branch{}, %{}, BN.current_user(conn), "new")

    managers =
      BN.list_user()
      |> Enum.map(fn x -> {x.username, x.id} end)
      |> Enum.sort_by(fn x -> elem(x, 0) end)

    organizations =
      BN.list_organization()
      |> Enum.map(fn x -> {x.organisationname, x.organisationid} end)
      |> Enum.sort_by(fn x -> elem(x, 0) end)

    menu_catalog =
      Repo.all(
        from(
          m in MenuCatalog,
          where: m.brand_id == ^BN.get_brand_id(conn),
          select: {m.name, m.id},
          order_by: [asc: m.name]
        )
      )

    disc_catalog =
      Repo.all(
        from(
          m in DiscountCatalog,
          where: m.brand_id == ^BN.get_brand_id(conn),
          select: {m.name, m.id},
          order_by: [asc: m.name]
        )
      )

    render(
      conn,
      "new.html",
      changeset: changeset,
      managers: managers,
      organizations: organizations,
      menu_catalog: menu_catalog,
      disc_catalog: disc_catalog
    )
  end

  def tbl_syn(conn, params) do
    branchs = Repo.all(from(m in MenuCatalog, where: m.brand_id == ^BN.get_brand_id(conn)))

    for branch <- branchs do
      tags =
        Repo.all(
          from(
            m in Tag,
            where: m.tagid >= 1 and m.tagid <= 5 and m.brand_id == ^BN.get_brand_id(conn),
            select: %{
              id: m.tagid,
              tagname: m.tagname,
              tagdesc: m.tagdesc,
              printer: m.printer,
              branch_id: m.branch_id
            }
          )
        )

      for tag <- tags do
        BN.create_tag(%{
          tagname: tag.tagname,
          tagdesc: tag.tagdesc,
          printer: tag.printer,
          branch_id: branch.id
        })
      end

      chicken = Repo.get_by(Tag, tagdesc: "CHICKEN", branch_id: branch.id)

      BN.update_tag(chicken, %{subcat_ids: branch.items})
    end

    conn
    |> put_flash(:info, "Successfully synronize")
    |> redirect(to: branch_path(conn, :index, BN.get_domain(conn)))
  end

  def tbl_syn_combo(conn, params) do
    combo_details =
      Repo.all(
        from(
          s in ComboDetails,
          where: s.brand_id == ^BN.get_brand_id(conn),
          select: %{combo_item_id: s.combo_item_id}
        )
      )

    for combo_detail <- combo_details do
      id = combo_detail.combo_item_id

      a = id |> Integer.to_string() |> String.split_at(6) |> elem(1)

      printers =
        Repo.all(
          from(
            s in Tag,
            where: s.brand_id == ^BN.get_brand_id(conn),
            select: %{tagid: s.tagid, subcat_ids: s.subcat_ids, combo_item_ids: s.combo_item_ids}
          )
        )

      for printer <- printers do
        subcatids = printer.subcat_ids

        if subcatids != nil do
          all = subcatids |> String.split(",")

          if Enum.any?(all, fn x -> x == a end) do
            combo_id = id |> Integer.to_string()
            comboitemids = printer.combo_item_ids
            comb = comboitemids |> String.split(",")
            all_items = List.insert_at(comb, 0, combo_id)
            new_items = all_items |> Enum.join(",")

            tag = Repo.get_by(Tag, tagid: printer.tagid, brand_id: BN.get_brand_id(conn))

            BN.update_tag(tag, %{combo_item_ids: new_items})
          end
        end
      end
    end

    conn
    |> put_flash(:info, "Successfully synronize")
    |> redirect(to: branch_path(conn, :index, BN.get_domain(conn)))
  end

  def create(conn, %{"branch" => branch_params}) do
    latest_branch_id =
      Repo.all(
        from(
          b in Branch,
          where: b.brand_id == ^BN.get_brand_id(conn),
          select: b.branchid,
          order_by: [desc: b.branchid]
        )
      )

    latest_branch_id =
      if latest_branch_id == [] do
        0
      else
        hd(latest_branch_id)
      end

    branch_params = Map.put(branch_params, "branchid", latest_branch_id + 1)
    branch_params = Map.put(branch_params, "brand_id", BN.get_brand_id(conn))

    changeset =
      BoatNoodle.BN.Branch.changeset(
        %BoatNoodle.BN.Branch{},
        branch_params,
        BN.current_user(conn),
        "Create"
      )

    case BoatNoodle.Repo.insert(changeset) do
      {:ok, branch} ->
        conn
        |> put_flash(:info, "Branch created successfully.")
        |> redirect(to: branch_path(conn, :show, branch.branchid, BN.get_brand_id(conn)))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Branch not created.")
        |> redirect(to: branch_path(conn, :index, BN.get_brand_id(conn)))
    end
  end

  def show(conn, %{"id" => id, "brand" => brand}) do
    branch = Repo.get_by(Branch, branchid: id, brand_id: BN.get_brand_id(conn))
    render(conn, "show.html", branch: branch)
  end

  def edit(conn, %{"id" => id}) do
    branch =
      Repo.all(
        from(b in Branch, where: b.branchid == ^id and b.brand_id == ^BN.get_brand_id(conn))
      )
      |> hd()

    branch =
      if branch.payment_catalog == nil do
        {:ok, branch} =
          Branch.changeset(branch, %{payment_catalog: "0"}, BN.current_user(conn), "Update")
          |> Repo.update()

        branch
      else
        branch
      end

    payment_catalog =
      branch.payment_catalog |> String.split(",") |> Enum.filter(fn x -> x != "" end)

    selected =
      for item <- payment_catalog do
        payment =
          Repo.get_by(PaymentType, %{
            payment_type_id: item,
            brand_id: BN.get_brand_id(conn)
          })

        if payment != nil do
          %{
            payment_type_id: payment.payment_type_id,
            payment_type_code: payment.payment_type_code,
            payment_type_name: payment.payment_type_name
          }
        end
      end
      |> Enum.reject(fn x -> x == nil end)

    all_payment_type =
      Repo.all(
        from(
          b in BoatNoodle.BN.PaymentType,
          where: b.brand_id == ^BN.get_brand_id(conn),
          select: %{
            payment_type_id: b.payment_type_id,
            payment_type_code: b.payment_type_code,
            payment_type_name: b.payment_type_name
          }
        )
      )

    unselected = all_payment_type -- selected

    changeset = BoatNoodle.BN.Branch.changeset(branch, %{}, BN.current_user(conn), "edit")

    managers =
      BN.list_user()
      |> Enum.filter(fn x -> x.brand_id == BN.get_brand_id(conn) end)
      |> Enum.map(fn x -> {x.username, x.id} end)
      |> Enum.sort_by(fn x -> elem(x, 0) end)

    organizations =
      Repo.all(
        from(
          b in Branch,
          left_join: o in Organization,
          on: b.org_id == o.organisationid,
          left_join: u in User,
          on: u.id == b.manager,
          where: b.brand_id == ^BN.get_brand_id(conn),
          select: %{
            org_id: o.organisationid,
            org_name: o.organisationname
          }
        )
      )
      |> Enum.uniq()
      |> Enum.filter(fn x -> x.org_id != nil end)

    # organizations =
    #   BN.list_organization()
    #   |> Enum.filter(fn x -> x.brand_id == BN.get_brand_id(conn) end)
    #   |> Enum.map(fn x -> {x.organisationname, x.organisationid} end)
    #   |> Enum.sort_by(fn x -> elem(x, 0) end)

    menu_catalog =
      Repo.all(
        from(
          m in MenuCatalog,
          where: m.brand_id == ^BN.get_brand_id(conn),
          select: {m.name, m.id},
          order_by: [asc: m.name]
        )
      )

    disc_catalog =
      Repo.all(
        from(
          m in DiscountCatalog,
          where: m.brand_id == ^BN.get_brand_id(conn),
          select: {m.name, m.id},
          order_by: [asc: m.name]
        )
      )

    current_menu_catalog =
      Repo.get_by(MenuCatalog, id: branch.menu_catalog, brand_id: BN.get_brand_id(conn))

    combo_items =
      if current_menu_catalog == nil do
        []
      else
        current_menu_catalog.items
        |> String.split(",")
        |> Enum.filter(fn x -> String.length(x) == 6 end)
      end

    items =
      if current_menu_catalog == nil do
        []
      else
        current_menu_catalog.items
        |> String.split(",")
        |> Enum.filter(fn x -> String.length(x) != 6 end)
      end

    all_item =
      Repo.all(
        from(
          i in ItemSubcat,
          where: i.subcatid in ^items and i.brand_id == ^BN.get_brand_id(conn)
        )
      )

    combos =
      Repo.all(
        from(
          i in ItemSubcat,
          where: i.subcatid in ^combo_items and i.brand_id == ^BN.get_brand_id(conn)
        )
      )

    combo_details =
      for combo <- combos do
        Repo.all(
          from(
            c in ComboDetails,
            where:
              c.combo_id == ^combo.subcatid and c.brand_id == ^BN.get_brand_id(conn) and
                c.is_delete == ^0
          )
        )
      end
      |> List.flatten()

    item_details =
      for item <- all_item do
        Repo.all(
          from(
            c in ItemSubcat,
            where:
              c.subcatid == ^item.subcatid and c.brand_id == ^BN.get_brand_id(conn) and
                c.is_delete == ^0
          )
        )
      end
      |> List.flatten()

    render(
      conn,
      "edit.html",
      branch: branch,
      changeset: changeset,
      managers: managers,
      organizations: organizations,
      menu_catalog: menu_catalog,
      disc_catalog: disc_catalog,
      selected: selected,
      unselected: unselected,
      combo_details: combo_details,
      item_details: item_details
    )
  end

  def update(conn, %{"id" => id, "branch" => branch_params}) do
    branch = Repo.get_by(Branch, branchid: id, brand_id: BN.get_brand_id(conn))

    changeset =
      BoatNoodle.BN.Branch.changeset(branch, branch_params, BN.current_user(conn), "Update")

    case BoatNoodle.Repo.update(changeset) do
      {:ok, branch} ->
        conn
        |> put_flash(:info, "Branch updated successfully.")
        |> redirect(to: branch_path(conn, :index, BN.get_domain(conn)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", branch: branch, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    branch = Repo.get_by(Branch, branchid: id, brand_id: BN.get_brand_id(conn))
    {:ok, _branch} = BN.delete_branch(branch)

    conn
    |> put_flash(:info, "Branch deleted successfully.")
    |> redirect(to: branch_path(conn, :index, BN.get_domain(conn)))
  end
end
