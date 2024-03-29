defmodule BoatNoodleWeb.ApiController do
  use BoatNoodleWeb, :controller
  use Task
  import Ecto.Query
  require IEx

  def webhook_post_operations(conn, params) do
    cond do
      params["scope"] == nil ->
        message = List.insert_at(conn.req_headers, 0, {"scope", "scope value is empty"})
        log_error_api(message, "API POST")
        send_resp(conn, 400, "please include scope.")

      params["key"] == nil ->
        message = List.insert_at(conn.req_headers, 0, {"api key", "key value is empty"})
        log_error_api(message, "API POST")
        send_resp(conn, 400, "please include key .")

      params["code"] == nil ->
        message = List.insert_at(conn.req_headers, 0, {"branch code", "code value is empty"})
        log_error_api(message, "API POST")
        send_resp(conn, 400, "please include code .")

      params["code"] != nil and params["key"] != nil and params["scope"] != nil ->
        user = Repo.get_by(Branch, branchcode: params["code"], api_key: params["key"])

        if user != nil do
          case params["scope"] do
            "voucher_codes" ->
              push_scope_voucher_codes(conn, params, user)

            "cash_in_out" ->
              push_scope_cash_in_out(conn, params, user)

            "shift_details" ->
              push_scope_shift_detail(conn, params, user)

            "void_receipt" ->
              push_scope_void_receipt(conn, params, user)

            "void_sales" ->
              push_scope_void_sales(conn, params, user)

            "restaurant_status" ->
              push_restaurant_status(conn, params, user)

            _ ->
              send_resp(conn, 500, "requested scope not available. \n")
          end
        else
          cond do
            user == nil ->
              message =
                List.insert_at(
                  conn.req_headers,
                  0,
                  {"authentication", "code and key doesnt match"}
                )

              message =
                List.insert_at(
                  conn.req_headers,
                  0,
                  {"requester", params["code"]}
                )

              log_error_api(message, params["code"] <> " API POST -" <> params["scope"])
              send_resp(conn, 400, "User not found.")

            true ->
              message =
                List.insert_at(
                  conn.req_headers,
                  0,
                  {"requester", params["code"]}
                )

              message = List.insert_at(conn.req_headers, 0, {"authentication", "unknown"})
              log_error_api(message, params["code"] <> " API POST -" <> params["scope"])
              send_resp(conn, 400, "user credentials are incorrect.")
          end
        end

      true ->
        send_resp(conn, 500, "please contact system admin. \n")
    end
  end

  def push_scope_voucher_codes(conn, params, user) do
    params = Map.put(params, "branch_id", user.branchid)
    params = Map.put(params, "brand_id", user.brand_id)
    # post the cash in cash out shits...
    cg = BoatNoodle.BN.VoucherCode.changeset(%BoatNoodle.BN.VoucherCode{}, params)

    case Repo.insert(cg) do
      {:ok, ci} ->
        Task.start_link(__MODULE__, :log_api, [
          IO.inspect(ci),
          params["code"] <> " API POST -" <> params["scope"],
          user.brand_id,
          user.branchid
        ])

        map = %{status: "ok"} |> Poison.encode!()
        send_resp(conn, 200, map)

      {:error, changeset} ->
        model_insert_error(conn, changeset, params)
        send_resp(conn, 500, "not ok")
    end
  end

  def push_scope_void_receipt(conn, params, user) do
    params = Map.put(params, "branch_id", user.branchid)
    params = Map.put(params, "brand_id", user.brand_id)
    IO.inspect(params)
    cg = BoatNoodle.BN.VoidItems.changeset(%BoatNoodle.BN.VoidItems{}, params)

    case Repo.insert(cg) do
      {:ok, ci} ->
        Task.start_link(__MODULE__, :log_api, [
          IO.inspect(ci),
          params["code"] <> " API POST -" <> params["scope"],
          user.brand_id,
          user.branchid
        ])

        map = %{status: "ok"} |> Poison.encode!()
        send_resp(conn, 200, map)

      {:error, changeset} ->
        model_insert_error(conn, changeset, params)
        send_resp(conn, 500, "not ok")
    end
  end

  def push_scope_void_sales(conn, params, user) do
    params = Map.put(params, "branch_id", user.branchid)
    params = Map.put(params, "brand_id", user.brand_id)
    IO.inspect(params)

    sales = Repo.get_by(Sales, brand_id: user.brand_id, salesid: params["salesid"])

    cg =
      Sales.changeset(sales, %{
        is_void: 1,
        void_by: params["staff_id"],
        voidreason: params["void_reason"]
      })

    case Repo.update(cg) do
      {:ok, ci} ->
        Task.start_link(__MODULE__, :log_api, [
          IO.inspect(ci),
          params["code"] <> " API POST -" <> params["scope"],
          user.brand_id,
          user.branchid
        ])

        map = %{status: "ok"} |> Poison.encode!()
        send_resp(conn, 200, map)

      {:error, changeset} ->
        model_insert_error(conn, changeset, params)
        send_resp(conn, 500, "not ok")
    end
  end

  def push_restaurant_status(conn, params, user) do
    params = Map.put(params, "branch_id", user.branchid)
    params = Map.put(params, "brand_id", user.brand_id)

    a =
      Branch.changeset(
        user,
        %{
          sync_by: params["current_user"],
          unsync: params["unsync"],
          version2: params["version"],
          sidepos2: params["sidepos"],
          last_sync: Timex.now()
        },
        0,
        "Update"
      )
      |> Repo.update()

    IO.inspect(a)

    # update_rest_status(user.brand_id, user.branchid, params)

    map = %{status: "ok"} |> Poison.encode!()
    send_resp(conn, 200, map)
  end

  def push_scope_shift_detail(conn, params, user) do
    params = Map.put(params, "branch_id", user.branchid)
    params = Map.put(params, "brand_id", user.brand_id)
    params = Map.put(params, "totalpax", :erlang.trunc(params["totalpax"]))
    params = Map.put(params, "branchcode", params["code"])

    cg = BoatNoodle.BN.RPTCASHIEREOD.changeset(%BoatNoodle.BN.RPTCASHIEREOD{}, params)
    # IO.inspect(cg)
    # IO.inspect(params)

    case Repo.insert(cg) do
      {:ok, ci} ->
        Task.start_link(__MODULE__, :log_api, [
          IO.inspect(ci),
          params["code"] <> " API POST -" <> params["scope"],
          user.brand_id,
          user.branchid
        ])

        map = %{status: "ok"} |> Poison.encode!()
        send_resp(conn, 200, map)

      {:error, changeset} ->
        IO.inspect(changeset)
        model_insert_error(conn, changeset, params)
        send_resp(conn, 500, "not ok")
    end
  end

  def push_scope_cash_in_out(conn, params, user) do
    params = Map.put(params, "branch_id", user.branchid)
    params = Map.put(params, "brand_id", user.brand_id)

    if params["description"] == "" do
      params = Map.put(params, "description", "empty descriptions")
    end

    # post the cash in cash out shits...
    cg = BoatNoodle.BN.CashInOut.changeset(%BoatNoodle.BN.CashInOut{}, params)

    case Repo.insert(cg) do
      {:ok, ci} ->
        Task.start_link(__MODULE__, :log_api, [
          IO.inspect(ci),
          params["code"] <> " API POST -" <> params["scope"],
          user.brand_id,
          user.branchid
        ])

        map = %{status: "ok"} |> Poison.encode!()
        send_resp(conn, 200, map)

      {:error, changeset} ->
        model_insert_error(conn, changeset, params)
        send_resp(conn, 500, "not ok")
    end
  end

  def model_insert_error(conn, changeset, params) do
    model = changeset.errors |> hd() |> elem(0) |> Atom.to_string()
    type = changeset.errors |> hd() |> elem(1) |> elem(0)
    message = List.insert_at(conn.req_headers, 0, {model, type})

    message =
      List.insert_at(
        conn.req_headers,
        0,
        {"requester", params["code"]}
      )

    log_error_api(message, params["code"] <> " API POST -" <> params["scope"])
  end

  def webhook_get(conn, params) do
    cond do
      params["key"] == nil ->
        send_resp(conn, 200, "please include key .")

      params["fields"] == nil ->
        send_resp(conn, 200, "please include sales id in field.")

      params["fields"] != nil and params["key"] != nil and params["code"] != nil ->
        brb = Repo.get_by(Branch, branchcode: params["code"], api_key: params["key"])

        if brb != nil do
          branch = Repo.get_by(Branch, branchcode: params["code"], api_key: params["key"])

          if branch != nil do
            case params["fields"] do
              "sales_id" ->
                get_scope_sales_id(conn, branch.branchid, branch.brand_id, params["code"])

              "printers" ->
                get_scope_branch_printer(conn, branch.branchid, branch.brand_id, params["code"])

              "items" ->
                get_scope_branch_items(
                  conn,
                  branch.branchid,
                  branch.brand_id,
                  params["code"],
                  branch.menu_catalog
                )

              "branch_details" ->
                get_scope_branch_details(conn, branch)

              "vouchers" ->
                get_scope_vouchers(conn, branch.branchid, branch.brand_id, params["code"])

              "item_remarks" ->
                get_scope_item_remarks(conn, branch.branchid, branch.brand_id, params["code"])

              "staffs" ->
                get_scope_staffs(conn, branch.branchid, branch.brand_id, params["code"])

              "payment_types" ->
                get_scope_payment_types(conn, branch.branchid, branch.brand_id, params["code"])

              "date_price" ->
                get_scope_date_price(conn, branch.branchid, branch.brand_id, params["code"])

              "discount" ->
                # IO.inspect(branch.branchid)

                get_scope_discount(
                  conn,
                  branch.branchid,
                  branch.brand_id,
                  params["code"],
                  branch.disc_catalog
                )

              _ ->
                message =
                  List.insert_at(conn.req_headers, 0, {"fields", "not within defined fields"})

                message =
                  List.insert_at(
                    conn.req_headers,
                    0,
                    {"requester", params["code"]}
                  )

                log_error_api(message, "API GET")
                send_resp(conn, 200, "request not available. \n")
            end
          else
            message = List.insert_at(conn.req_headers, 0, {"branch", "db cant find branch"})

            message =
              List.insert_at(
                conn.req_headers,
                0,
                {"requester", params["code"]}
              )

            log_error_api(message, "API GET")
            send_resp(conn, 200, "branch doesnt exist. \n")
          end
        else
          message = List.insert_at(conn.req_headers, 0, {"authentication", "wrong combination"})

          message =
            List.insert_at(
              conn.req_headers,
              0,
              {"requester", params["code"]}
            )

          log_error_api(message, "API GET")

          send_resp(conn, 200, "branch doesnt exist. \n")
        end
    end
  end

  def get_scope_discount(conn, branch_id, brand_id, branchcode, disc_catalog_id) do
    # get the branch discount catalog
    # IO.inspect(branch_id)
    disc_catalog = Repo.get_by(DiscountCatalog, id: disc_catalog_id, brand_id: brand_id)
    # IO.inspect(disc_catalog)

    ids =
      disc_catalog.categories
      |> String.split(",")
      |> Enum.sort()
      |> Enum.reject(fn x -> x == "" end)
      |> Enum.map(fn x -> String.to_integer(x) end)

    # IO.inspect(ids)

    item_ids =
      disc_catalog.discounts
      |> String.split(",")
      |> Enum.sort()
      |> Enum.reject(fn x -> x == "" end)
      |> Enum.map(fn x -> String.to_integer(x) end)

    # IO.inspect(item_ids)
    # arrange the discount category
    disc_categories =
      Repo.all(
        from(
          d in Discount,
          where: d.discountid in ^ids and d.brand_id == ^brand_id and d.is_visable == ^1,
          select: %{
            brand_id: d.brand_id,
            DiscountID: d.discountid,
            DiscName: d.discname,
            Descriptions: d.descriptions,
            DiscAmtPercentage: d.discamtpercentage,
            target_cat: d.target_cat,
            is_used: d.is_used,
            disc_qty: d.disc_qty,
            target_itemcode: d.target_itemcode,
            DiscType: d.disctype,
            is_categorize: d.is_categorize,
            is_visable: d.is_visable
          }
        )
      )

    # IO.inspect(disc_categories)

    disc_items =
      Repo.all(
        from(
          d in DiscountItem,
          where:
            d.discountitemsid in ^item_ids and d.brand_id == ^brand_id and d.is_visable == ^1,
          select: %{
            brand_id: d.brand_id,
            discountitemsid: d.discountitemsid,
            min_spend: d.min_spend,
            pre_req_item: d.pre_req_item,
            is_delete: d.is_delete,
            is_visable: d.is_visable,
            min_order: d.min_order,
            is_targetmenuitems: d.is_targetmenuitems,
            multi_item_list: d.multi_item_list,
            is_categorize: d.is_categorize,
            disctype: d.disctype,
            disc_qty: d.disc_qty,
            is_used: d.is_used,
            target_cat: d.target_cat,
            discamtpercentage: d.discamtpercentage,
            descriptions: d.descriptions,
            discitemsname: d.discitemsname,
            discountid: d.discountid,
            is_force_apply: d.is_force_apply,
            is_oc: d.is_oc
          }
        )
      )
      |> Enum.map(fn x ->
        %{
          brand_id: x.brand_id,
          DiscountItemsID: x.discountitemsid,
          min_spend: x.min_spend,
          pre_req_item: x.pre_req_item,
          is_delete: x.is_delete,
          is_visable: x.is_visable,
          min_order: x.min_order,
          is_targetMenuItems: x.is_targetmenuitems,
          multi_item_list: x.multi_item_list,
          is_categorize: x.is_categorize,
          DiscType: x.disctype,
          disc_qty: x.disc_qty,
          is_used: x.is_used,
          target_cat: x.target_cat,
          DiscAmtPercentage: x.discamtpercentage,
          Descriptions: x.descriptions,
          DiscItemsName: x.discitemsname,
          DiscountID: x.discountid,
          is_force_apply: bol(x.is_force_apply),
          is_oc: x.is_oc
        }
      end)

    discount_date =
      Repo.all(
        from(
          d in BoatNoodle.BN.DateDiscount,
          where: d.brand_id == ^brand_id and d.is_delete == ^0,
          select: %{
            start_date: d.start_date,
            end_date: d.end_date,
            discountitemsid: d.discountitems_id
          }
        )
      )

    # IO.inspect(disc_items)
    # arrange the discount item
    json_map =
      %{disc_categories: disc_categories, disc_items: disc_items, discount_date: discount_date}
      |> Poison.encode!()

    # IO.inspect(json_map)
    message = List.insert_at(conn.req_headers, 0, {"discount", "discount"})
    log_error_api(message, "#{branchcode} - API GET - discount")
    # IO.inspect(message)
    send_resp(conn, 200, json_map)
  end

  def bol(boolean) do
    if boolean do
      1
    else
      0
    end
  end

  def get_scope_date_price(conn, branch_id, brand_id, branchcode) do
    date_prices =
      Repo.all(
        from(
          d in DatePrice,
          where: d.brand_id == ^brand_id,
          select: %{
            start_date: d.start_date,
            end_date: d.end_date,
            unit_price: d.unit_price,
            menuitemid: d.item_subcat_id
          }
        )
      )

    map_json = %{date_prices: date_prices} |> Poison.encode!()

    message = List.insert_at(conn.req_headers, 0, {"date_prices", "date_prices"})
    log_error_api(message, "#{branchcode} - API GET - date_prices")
    send_resp(conn, 200, map_json)
  end

  def get_scope_payment_types(conn, branch_id, brand_id, branchcode) do
    payment_types =
      Repo.all(
        from(
          x in PaymentType,
          where: x.brand_id == ^brand_id,
          select: %{
            is_visible: x.is_visible,
            is_default: x.is_default,
            is_code: x.is_payment_code,
            is_cardno: x.is_card_no,
            paymenttypeid: x.payment_type_id,
            otherpaymentcode: x.payment_type_code,
            otherpaymentname: x.payment_type_name,
            is_delivery: x.is_delivery
          }
        )
      )

    map_json = %{payment_types: payment_types} |> Poison.encode!()

    message = List.insert_at(conn.req_headers, 0, {"payment_types", "payment_types"})
    log_error_api(message, "#{branchcode} - API GET - payment_types")
    send_resp(conn, 200, map_json)
  end

  def get_scope_staffs(conn, branch_id, brand_id, branchcode) do
    staffs =
      Repo.all(
        from(
          v in Staff,
          where: v.brand_id == ^brand_id,
          select: %{
            brand_id: v.brand_id,
            staff_id: v.staff_id,
            branch_access: v.branch_access,
            staff_name: v.staff_name,
            staff_contact: v.staff_contact,
            staff_email: v.staff_email,
            staff_pin: v.staff_pin,
            branchid: v.branchid,
            staff_type_id: v.staff_type_id,
            prof_img: v.prof_img
          }
        )
      )
      |> Enum.reject(fn x -> x.branch_access == nil end)

    # IO.inspect(staffs)

    final_staffs =
      staffs
      |> Enum.map(fn x ->
        %{
          brand_id: x.brand_id,
          staff_id: x.staff_id,
          branch_access: String.split(x.branch_access, ","),
          staff_name: x.staff_name,
          staff_contact: x.staff_contact,
          staff_email: x.staff_email,
          staff_pin: x.staff_pin,
          branchid: x.branchid,
          staff_type_id: x.staff_type_id,
          prof_img: x.prof_img
        }
      end)
      |> Enum.filter(fn x ->
        Enum.any?(x.branch_access, fn y -> y == Integer.to_string(branch_id) end)
      end)

    super_staffs =
      staffs
      |> Enum.map(fn x ->
        %{
          brand_id: x.brand_id,
          staff_id: x.staff_id,
          branch_access: String.split(x.branch_access, ","),
          staff_name: x.staff_name,
          staff_contact: x.staff_contact,
          staff_email: x.staff_email,
          staff_pin: x.staff_pin,
          branchid: x.branchid,
          staff_type_id: x.staff_type_id,
          prof_img: x.prof_img
        }
      end)
      |> Enum.filter(fn x ->
        Enum.any?(x.branch_access, fn y -> y == "0" end)
      end)

    staff_data = super_staffs ++ final_staffs
    staff_list = %{staffs: staff_data} |> Poison.encode!()

    message = List.insert_at(conn.req_headers, 0, {"staffs", "staffs"})
    log_error_api(message, "#{branchcode} - API GET - staffs")
    send_resp(conn, 200, staff_list)
  end

  def get_scope_item_remarks(conn, branch_id, brand_id, branchcode) do
    item_remarks =
      Repo.all(
        from(
          v in Remark,
          where: v.brand_id == ^brand_id,
          select: %{
            itemsremarkid: v.itemsremarkid,
            remark: v.remark,
            target_cat: v.target_cat,
            target_item: v.target_item
          }
        )
      )

    map_json = %{item_remarks: item_remarks} |> Poison.encode!()

    message = List.insert_at(conn.req_headers, 0, {"item remarks", "item remarks"})
    log_error_api(message, "#{branchcode} - API GET - item remarks")
    send_resp(conn, 200, map_json)
  end

  def get_scope_vouchers(conn, branch_id, brand_id, branchcode) do
    vouchers =
      Repo.all(
        from(
          v in Voucher,
          select: %{
            id: v.id,
            code_number: v.code_number,
            discount_name: v.discount_name,
            is_used: v.is_used,
            branchid: v.branchid
          }
        )
      )
      |> Enum.map(fn x ->
        %{
          id: x.id,
          code_number: x.code_number,
          discount_name: x.discount_name,
          is_used: bol(x.is_used),
          branchid: x.branchid
        }
      end)

    json_map = %{vouchers: vouchers} |> Poison.encode!()

    message = List.insert_at(conn.req_headers, 0, {"vouchers", "vouchers"})
    log_error_api(message, "#{branchcode} - API GET - vouchers")
    send_resp(conn, 200, json_map)
  end

  def get_scope_branch_details(conn, branch) do
    b = branch
    org = Repo.get(Organization, b.org_id)
    bb = Repo.get(Brand, b.brand_id)

    branch_details =
      %{
        api_key: b.api_key,
        brand_id: b.brand_id,
        payment_catalog: b.payment_catalog,
        version: b.version,
        tag_catalog: b.tag_catalog,
        disc_catalog: b.disc_catalog,
        menu_catalog: b.menu_catalog,
        remain_sync: b.remain_sync,
        sync_status: b.sync_status,
        currency: b.currency,
        qb_dep2acc: b.qb_dep2acc,
        qb_custref: b.qb_custref,
        branchid: b.branchid,
        branchname: b.branchname,
        branchcode: b.branchcode,
        b_phoneno: b.b_phoneno,
        b_address: b.b_address,
        org_id: b.org_id,
        tax_percent: b.tax_percent,
        service_charge: b.service_charge,
        manager: b.manager,
        num_staff: b.num_staff,
        report_class: b.report_class,
        reg_id: org.orgregid,
        gst_id: org.gst_reg_id,
        comp_address: org.address,
        def_open_amt: b.def_open_amt,
        tax_symbol: bb.tax_code
      }
      |> Poison.encode!()

    message = List.insert_at(conn.req_headers, 0, {"branch_details", "branch_details"})
    log_error_api(message, "#{branch.branchcode} - API GET - branch_details")
    send_resp(conn, 200, branch_details)
  end

  def get_scope_branch_items(conn, branch_id, brand_id, branchcode, menu_cat_id) do
    menu_catalog = Repo.get_by(MenuCatalog, id: menu_cat_id, brand_id: brand_id)
    cat_ids = menu_catalog.categories |> String.split(",") |> Enum.reject(fn x -> x == "" end)
    subcat_ids = menu_catalog.items |> String.split(",") |> Enum.reject(fn x -> x == "" end)
    combo_ids = menu_catalog.combo_items |> String.split(",") |> Enum.reject(fn x -> x == "" end)

    item_cats =
      Repo.all(
        from(
          i in ItemCat,
          where: i.itemcatid in ^cat_ids and i.brand_id == ^brand_id and i.visable == ^1
        )
      )
      |> Enum.map(fn x ->
        %{
          # brand_id: x.brand_id,
          itemcatid: x.itemcatid,
          itemcatcode: x.itemcatcode,
          itemcatname: x.itemcatname,
          itemcatdesc: x.itemcatdesc,
          is_default: x.is_default,
          visable: x.visable,
          category_img: x.category_img,
          sort_no: x.sort_no
          # category_type: x.category_type,
          # created_at: x.created_at,
          # updated_at: x.updated_at
        }
      end)

    subcats =
      Repo.all(
        from(
          s in ItemSubcat,
          where:
            s.subcatid in ^subcat_ids and s.brand_id == ^brand_id and s.is_activate != ^0 and
              s.is_delete == ^0
        )
      )
      |> Enum.map(fn x ->
        %{
          # brand_id: x.brand_id,
          subcatid: x.subcatid,
          itemcatid: x.itemcatid,
          itemname: x.itemname,
          itemcode: x.itemcode,
          price: x.itemprice,
          is_categorize: x.is_categorize,
          is_activate: x.is_activate,
          is_default_combo: x.is_default_combo,
          enable_disc: x.enable_disc,
          include_spend: x.include_spend,
          is_print: x.is_print,
          disc_reminder: x.disc_reminder,
          item_start_hour: x.item_start_hour,
          item_end_hour: x.item_end_hour

          # product_code: x.product_code,
          # price_code: x.price_code,
          # part_code: x.part_code,
          # itemdesc: x.itemdesc,
          # itemimage: x.itemimage,
          # is_comboitem: x.is_comboitem,
          # is_delete: x.is_delete,
        }
      end)

    combo_items =
      subcat_ids
      |> Enum.filter(fn x -> String.length(x) == 6 end)

    combos2 =
      Repo.all(
        from(
          i in ItemSubcat,
          where: i.subcatid in ^combo_items and i.brand_id == ^brand_id
        )
      )

    combos =
      for combo <- combos2 do
        Repo.all(
          from(
            c in ComboDetails,
            where:
              c.combo_id == ^combo.subcatid and c.brand_id == ^brand_id and c.is_delete == ^0,
            select: %{
              # brand_id: c.brand_id,
              id: c.id,
              menu_cat_id: c.menu_cat_id,
              combo_id: c.combo_id,
              combo_qty: c.combo_qty,
              combo_item_id: c.combo_item_id,
              combo_item_name: c.combo_item_name,
              combo_item_code: c.combo_item_code,
              # combo_item_qty: c.combo_item_qty,
              # update_qty: c.update_qty,
              top_up: c.top_up,
              unit_price: c.unit_price,
              is_default: c.is_default,
              is_delete: c.is_delete
            }
          )
        )
      end
      |> List.flatten()

    # combos =
    #   Repo.all(
    #     from(
    #       c in ComboDetails,
    #       where: c.id in ^combo_ids and c.brand_id == ^brand_id and c.is_delete == 0,
    #       select: %{
    #         # brand_id: c.brand_id,
    #         id: c.id,
    #         menu_cat_id: c.menu_cat_id,
    #         combo_id: c.combo_id,
    #         combo_qty: c.combo_qty,
    #         combo_item_id: c.combo_item_id,
    #         combo_item_name: c.combo_item_name,
    #         combo_item_code: c.combo_item_code,
    #         # combo_item_qty: c.combo_item_qty,
    #         # update_qty: c.update_qty,
    #         top_up: c.top_up,
    #         unit_price: c.unit_price,
    #         is_default: c.is_default,
    #         is_delete: c.is_delete
    #       }
    #     )
    #   )

    date_prices =
      Repo.all(
        from(
          d in DatePrice,
          where: d.brand_id == ^brand_id and d.is_delete == ^0,
          select: %{
            start_date: d.start_date,
            end_date: d.end_date,
            unit_price: d.unit_price,
            menuitemid: d.item_subcat_id
          }
        )
      )

    json_map =
      %{
        combo_details: combos,
        menuitems: subcats,
        menucategories: item_cats,
        date_prices: date_prices
      }
      |> Poison.encode!()

    if menu_catalog != nil do
      message = List.insert_at(conn.req_headers, 0, {"menu_catalog", "menu_catalog"})
      log_error_api(message, "#{branchcode} - API GET - menu_catalog items")
      send_resp(conn, 200, json_map)
    else
    end
  end

  def get_scope_branch_printer(conn, branch_id, brand_id, branchcode) do
    printers =
      Repo.all(from(p in Tag, where: p.branch_id == ^branch_id and p.brand_id == ^brand_id))
      |> Enum.map(fn x ->
        %{
          tagid: x.tagid,
          printer: x.printer,
          tagname: x.tagname,
          tagdesc: x.tagdesc,
          subcat_ids: x.subcat_ids,
          combo_item_ids: x.combo_item_ids,
          printer_ip: x.printer_ip
        }
      end)

    map_json =
      %{printers: printers}
      |> Poison.encode!()

    message = List.insert_at(conn.req_headers, 0, {"printer", "printer"})
    log_error_api(message, "#{branchcode} - API GET - printer")
    send_resp(conn, 200, map_json)
  end

  def get_scope_sales_id(conn, branch_id, brand_id, branchcode) do
    invoiceno =
      Repo.all(
        from(
          s in Sales,
          where: s.branchid == ^Integer.to_string(branch_id) and s.brand_id == ^brand_id,
          select: %{invoiceno: s.invoiceno},
          order_by: [s.invoiceno]
        )
      )
      |> Enum.map(fn x -> x.invoiceno end)
      |> Enum.map(fn x -> String.to_integer(x) end)

    invoiceno =
      if invoiceno == [] do
        0
      else
        invoiceno |> Enum.max()
      end

    id =
      invoiceno
      |> Integer.to_string()

    salesid = branchcode <> "" <> id
    json_map = %{salesid: salesid} |> Poison.encode!()

    message = List.insert_at(conn.req_headers, 0, {"sales id", "#{salesid}"})
    log_error_api(message, "#{branchcode} - API GET - sales")
    send_resp(conn, 200, id)
  end

  def webhook_post(conn, params) do
    IO.puts("incoming api post...")
    branchcode = params["code"]
    # IO.inspect(params)
    a_list = params["details"]

    cond do
      params["key"] == nil ->
        message = List.insert_at(conn.req_headers, 0, {"api key", "key value is empty"})
        log_error_api(message, "#{branchcode} - API POST")
        send_resp(conn, 400, "please include key .")

      params["code"] == nil ->
        message = List.insert_at(conn.req_headers, 0, {"branch code", "code value is empty"})
        log_error_api(message, "#{branchcode} - API POST")
        send_resp(conn, 400, "please include code .")

      true ->
        user = Repo.get_by(Branch, branchcode: params["code"], api_key: params["key"])

        if user != nil do
          sales_params =
            for {key, val} <- params["sales"], into: %{}, do: {String.to_atom(key), val}

          sales_master_params_list =
            for a <- a_list do
              sales_master_params = for {key, val} <- a, into: %{}, do: {String.to_atom(key), val}
            end

          sales_payment_params =
            for {key, val} <- params["payment"], into: %{}, do: {String.to_atom(key), val}

          if Map.get(sales_params, :salesid) == nil do
            invoiceno =
              Repo.all(
                from(
                  s in Sales,
                  where: s.branchid == ^sales_params.branchid and s.brand_id == ^user.brand_id,
                  select: %{
                    invoiceno: s.invoiceno
                  },
                  order_by: [s.invoiceno]
                )
              )
              |> Enum.map(fn x -> x.invoiceno end)
              |> Enum.map(fn x -> String.to_integer(x) end)
              |> Enum.max()

            brach_name =
              Repo.all(
                from(
                  b in Branch,
                  where: b.branchid == ^sales_params.branchid and b.brand_id == ^user.brand_id,
                  select: %{
                    branchcode: b.branchcode
                  }
                )
              )
              |> hd()

            id =
              (invoiceno + 1)
              |> Integer.to_string()

            salesid = brach_name.branchcode <> "" <> id

            sales_params = Map.put(sales_params, :salesid, salesid)
            # sales_params = Map.put(sales_params, :invoiceno, id)
          end

          sales_exist = Repo.get_by(Sales, salesid: sales_params.salesid)

          cond do
            sales_exist != nil ->
              message = List.insert_at(conn.req_headers, 0, {"sales id", "already exist"})
              log_error_api(message, "#{branchcode} - API POST - sales")

              map =
                %{message: "Sales #{sales_exist.salesid} already exist.", status: "existed"}
                |> Poison.encode!()

              send_resp(conn, 200, map)

            sales_exist == nil ->
              salesdate =
                NaiveDateTime.from_iso8601!(sales_params.salesdatetime) |> NaiveDateTime.to_date()

              sales_params = Map.put(sales_params, :salesdate, salesdate)

              sales_params =
                Map.put(sales_params, :tbl_no, Integer.to_string(sales_params.tbl_no))

              sales_params =
                Map.put(sales_params, :staffid, Integer.to_string(sales_params.staffid))

              sales_params =
                Map.put(sales_params, :invoiceno, Integer.to_string(sales_params.invoiceno))

              sales_params = Map.put(sales_params, :brand_id, user.brand_id)

              sales_params = Map.put(sales_params, :branchid, Integer.to_string(user.branchid))

              if user.is_test == 1 do
                sales_params = Map.put(sales_params, :is_void, 1)
                sales_params = Map.put(sales_params, :void_by, "Phoenix")
                sales_params = Map.put(sales_params, :voidreason, "Flag as is_test")
              end

              # IO.inspect(sales_params)
              sd_count = 0
              sd_count = Enum.count(sales_master_params_list)

              case BN.create_sales(sales_params) do
                {:ok, sales} ->
                  sales_payment_params = Map.put(sales_payment_params, :salesid, sales.salesid)
                  sales_payment_params = Map.put(sales_payment_params, :brand_id, user.brand_id)

                  Task.start_link(__MODULE__, :log_api, [
                    IO.inspect(sales),
                    params["code"],
                    user.branchid,
                    user.brand_id
                  ])

                  sd =
                    for sales_master_params <- sales_master_params_list do
                      sales_master_params = Map.put(sales_master_params, :salesid, sales.salesid)
                      sales_master_params = Map.put(sales_master_params, :brand_id, user.brand_id)

                      if user.is_test == 1 do
                        sales_master_params = Map.put(sales_master_params, :is_void, 1)
                        sales_master_params = Map.put(sales_master_params, :void_by, "Phoenix")

                        sales_master_params =
                          Map.put(sales_master_params, :voidreason, "Flag as is_test")
                      end

                      case BN.create_sales_master(sales_master_params) do
                        {:ok, sales_master} ->
                          Task.start_link(__MODULE__, :log_api, [
                            IO.inspect(sales_master),
                            params["code"],
                            user.branchid,
                            user.brand_id
                          ])

                          :ok

                        {:error, %Ecto.Changeset{} = changeset} ->
                          model = changeset.errors |> hd() |> elem(0) |> Atom.to_string()
                          type = changeset.errors |> hd() |> elem(1) |> elem(0)
                          message = List.insert_at(conn.req_headers, 0, {model, type})
                          log_error_api(message, params["code"] <> " API POST - sales details")
                          :error
                      end
                    end

                  if sd |> Enum.any?(fn x -> x == :error end) do
                    Repo.delete_all(
                      from(
                        s in SalesMaster,
                        where: s.salesid == ^sales.salesid and s.brand_id == ^user.brand_id
                      )
                    )

                    Repo.delete(sales)

                    message =
                      List.insert_at(
                        conn.req_headers,
                        0,
                        {"sales details",
                         "one of it has issues, the created sales and other sales details will be deleted."}
                      )

                    log_error_api(message, "#{branchcode} - API POST - sales details")
                    send_resp(conn, 500, "Sales master failed to create.")
                  else
                    case BN.create_sales_payment(sales_payment_params) do
                      {:ok, sales_payment} ->
                        Task.start_link(__MODULE__, :log_api, [
                          IO.inspect(sales_payment),
                          params["code"],
                          user.branchid,
                          user.brand_id
                        ])

                        Task.start_link(__MODULE__, :inform_sales_update, [
                          sales.brand_id,
                          sales.branchid,
                          sales.created_at
                        ])

                      {:error, %Ecto.Changeset{} = changeset} ->
                        model = changeset.errors |> hd() |> elem(0) |> Atom.to_string()
                        type = changeset.errors |> hd() |> elem(1) |> elem(0)
                        message = List.insert_at(conn.req_headers, 0, {model, type})
                        log_error_api(message, "#{branchcode} - API POST - sales payment")
                    end

                    sp =
                      Repo.get_by(SalesPayment, brand_id: user.brand_id, salesid: sales.salesid)

                    sds =
                      Repo.all(
                        from(
                          sd in SalesMaster,
                          where: sd.brand_id == ^user.brand_id and sd.salesid == ^sales.salesid
                        )
                      )

                    if sp != nil and Enum.count(sds) == sd_count do
                      map =
                        %{message: "Sales #{sales.salesid} create successfully.", status: "ok"}
                        |> Poison.encode!()

                      # Task.start_link(__MODULE__, :update_dashboard_1, [
                      #   user.brand_id
                      # ])

                      Task.start_link(__MODULE__, :update_voucher_code, [
                        sales.salesid
                      ])

                      send_resp(conn, 200, map)
                    else
                      Repo.delete_all(
                        from(
                          s in SalesMaster,
                          where: s.salesid == ^sales.salesid and s.brand_id == ^user.brand_id
                        )
                      )

                      Repo.delete(sales)

                      send_resp(conn, 500, "Sales payment failed to create.")
                    end
                  end

                {:error, %Ecto.Changeset{} = changeset} ->
                  model = changeset.errors |> hd() |> elem(0) |> Atom.to_string()
                  type = changeset.errors |> hd() |> elem(1) |> elem(0)
                  message = List.insert_at(conn.req_headers, 0, {model, type})
                  log_error_api(message, "#{branchcode} - API POST - sales")

                  send_resp(conn, 500, "Sales to create. Please use the latest sales ID")
              end
          end
        else
          cond do
            user == nil ->
              message =
                List.insert_at(
                  conn.req_headers,
                  0,
                  {"authentication", "code and key doesnt match"}
                )

              log_error_api(message, "#{branchcode} - API POST")
              send_resp(conn, 400, "User not found.")

            true ->
              message = List.insert_at(conn.req_headers, 0, {"authentication", "unknown"})
              log_error_api(message, "#{branchcode} - API POST")
              send_resp(conn, 400, "user credentials are incorrect.")
          end
        end
    end
  end

  def update_voucher_code(salesid) do
  end

  def webhook_post_v2(conn, params) do
    a_list = params["details"]
    b_list = params["payments"]
    IO.inspect(params)

    cond do
      params["key"] == nil ->
        message = List.insert_at(conn.req_headers, 0, {"api key", "key value is empty"})
        log_error_api(message, "API POST")
        send_resp(conn, 400, "please include key .")

      params["code"] == nil ->
        message = List.insert_at(conn.req_headers, 0, {"branch code", "code value is empty"})
        log_error_api(message, "API POST")
        send_resp(conn, 400, "please include code .")

      true ->
        user = Repo.get_by(Branch, branchcode: params["code"], api_key: params["key"])

        if user != nil do
          sales_params =
            for {key, val} <- params["sales"], into: %{}, do: {String.to_atom(key), val}

          sales_master_params_list =
            for a <- a_list do
              sales_master_params = for {key, val} <- a, into: %{}, do: {String.to_atom(key), val}
            end

          sales_payment_params_list =
            for b <- b_list do
              sales_payment_params =
                for {key, val} <- b, into: %{}, do: {String.to_atom(key), val}
            end

          if Map.get(sales_params, :salesid) == nil do
            invoiceno =
              Repo.all(
                from(
                  s in Sales,
                  where: s.branchid == ^sales_params.branchid and s.brand_id == ^user.brand_id,
                  select: %{
                    invoiceno: s.invoiceno
                  },
                  order_by: [s.invoiceno]
                )
              )
              |> Enum.map(fn x -> x.invoiceno end)
              |> Enum.map(fn x -> String.to_integer(x) end)
              |> Enum.max()

            brach_name =
              Repo.all(
                from(
                  b in Branch,
                  where: b.branchid == ^sales_params.branchid and b.brand_id == ^user.brand_id,
                  select: %{
                    branchcode: b.branchcode
                  }
                )
              )
              |> hd()

            id =
              (invoiceno + 1)
              |> Integer.to_string()

            salesid = brach_name.branchcode <> "" <> id

            sales_params = Map.put(sales_params, :salesid, salesid)
            # sales_params = Map.put(sales_params, :invoiceno, id)
          end

          sales_exist = Repo.get_by(Sales, salesid: sales_params.salesid)

          cond do
            sales_exist != nil ->
              message = List.insert_at(conn.req_headers, 0, {"sales id", "already exist"})
              log_error_api(message, "API POST - sales")

              map =
                %{message: "Sales #{sales_exist.salesid} already exist.", status: "existed"}
                |> Poison.encode!()

              send_resp(conn, 200, map)

            sales_exist == nil ->
              salesdate =
                NaiveDateTime.from_iso8601!(sales_params.salesdatetime) |> NaiveDateTime.to_date()

              sales_params = Map.put(sales_params, :salesdate, salesdate)

              sales_params =
                Map.put(sales_params, :tbl_no, Integer.to_string(sales_params.tbl_no))

              sales_params =
                Map.put(sales_params, :staffid, Integer.to_string(sales_params.staffid))

              sales_params =
                Map.put(sales_params, :invoiceno, Integer.to_string(sales_params.invoiceno))

              sales_params = Map.put(sales_params, :brand_id, user.brand_id)

              sales_params = Map.put(sales_params, :branchid, Integer.to_string(user.branchid))
              # IO.inspect(sales_params)
              sd_count = 0
              sd_count = Enum.count(sales_master_params_list)
              sp_count = 0
              sp_count = Enum.count(sales_payment_params_list)

              case BN.create_sales(sales_params) do
                {:ok, sales} ->
                  Task.start_link(__MODULE__, :log_api, [
                    IO.inspect(sales),
                    params["code"],
                    user.branchid,
                    user.brand_id
                  ])

                  sd =
                    for sales_master_params <- sales_master_params_list do
                      sales_master_params = Map.put(sales_master_params, :salesid, sales.salesid)
                      sales_master_params = Map.put(sales_master_params, :brand_id, user.brand_id)

                      case BN.create_sales_master(sales_master_params) do
                        {:ok, sales_master} ->
                          Task.start_link(__MODULE__, :log_api, [
                            IO.inspect(sales_master),
                            params["code"],
                            user.branchid,
                            user.brand_id
                          ])

                          :ok

                        {:error, %Ecto.Changeset{} = changeset} ->
                          model = changeset.errors |> hd() |> elem(0) |> Atom.to_string()
                          type = changeset.errors |> hd() |> elem(1) |> elem(0)
                          message = List.insert_at(conn.req_headers, 0, {model, type})
                          log_error_api(message, params["code"] <> " API POST - sales details")
                          :error
                      end
                    end

                  if sd |> Enum.any?(fn x -> x == :error end) do
                    Repo.delete_all(
                      from(
                        s in SalesMaster,
                        where: s.salesid == ^sales.salesid and s.brand_id == ^user.brand_id
                      )
                    )

                    Repo.delete(sales)

                    message =
                      List.insert_at(
                        conn.req_headers,
                        0,
                        {"sales details",
                         "one of it has issues, the created sales and other sales details will be deleted."}
                      )

                    log_error_api(message, params["code"] <> "API POST - sales details")
                    send_resp(conn, 500, "Sales master failed to create.")
                  else
                    sps =
                      for sales_payment_params <- sales_payment_params_list do
                        sales_payment_params =
                          Map.put(sales_payment_params, :salesid, sales.salesid)

                        sales_payment_params =
                          Map.put(sales_payment_params, :brand_id, user.brand_id)

                        case BN.create_sales_payment(sales_payment_params) do
                          {:ok, sales_payment} ->
                            Task.start_link(__MODULE__, :log_api, [
                              IO.inspect(sales_payment),
                              params["code"],
                              user.branchid,
                              user.brand_id
                            ])

                            Task.start_link(__MODULE__, :inform_sales_update, [
                              sales.brand_id,
                              sales.branchid,
                              sales.created_at
                            ])

                            :ok

                          {:error, %Ecto.Changeset{} = changeset} ->
                            model = changeset.errors |> hd() |> elem(0) |> Atom.to_string()
                            type = changeset.errors |> hd() |> elem(1) |> elem(0)
                            message = List.insert_at(conn.req_headers, 0, {model, type})
                            log_error_api(message, params["code"] <> "API POST - sales payment")
                            :error
                        end
                      end

                    if sps |> Enum.any?(fn x -> x == :error end) do
                      Repo.delete_all(
                        from(
                          s in SalesPayment,
                          where: s.salesid == ^sales.salesid and s.brand_id == ^user.brand_id
                        )
                      )

                      Repo.delete_all(
                        from(
                          s in SalesMaster,
                          where: s.salesid == ^sales.salesid and s.brand_id == ^user.brand_id
                        )
                      )

                      Repo.delete(sales)

                      message =
                        List.insert_at(
                          conn.req_headers,
                          0,
                          {"sales details",
                           "one of it has issues, the created sales and other sales details will be deleted."}
                        )

                      log_error_api(message, "API POST - sales details")
                      send_resp(conn, 500, "Sales master failed to create.")
                    else
                      sps =
                        Repo.all(
                          from(
                            s in SalesPayment,
                            where: s.brand_id == ^user.brand_id and s.salesid == ^sales.salesid
                          )
                        )

                      sds =
                        Repo.all(
                          from(
                            sd in SalesMaster,
                            where: sd.brand_id == ^user.brand_id and sd.salesid == ^sales.salesid
                          )
                        )

                      if Enum.count(sps) == sp_count and Enum.count(sds) == sd_count do
                        map =
                          %{message: "Sales #{sales.salesid} create successfully.", status: "ok"}
                          |> Poison.encode!()

                        # Task.start_link(__MODULE__, :update_dashboard_1, [
                        #   user.brand_id
                        # ])

                        send_resp(conn, 200, map)
                      else
                        Repo.delete_all(
                          from(
                            s in SalesPayment,
                            where: s.salesid == ^sales.salesid and s.brand_id == ^user.brand_id
                          )
                        )

                        Repo.delete_all(
                          from(
                            s in SalesMaster,
                            where: s.salesid == ^sales.salesid and s.brand_id == ^user.brand_id
                          )
                        )

                        Repo.delete(sales)

                        send_resp(conn, 500, "Sales payment failed to create.")
                      end
                    end
                  end

                {:error, %Ecto.Changeset{} = changeset} ->
                  model = changeset.errors |> hd() |> elem(0) |> Atom.to_string()
                  type = changeset.errors |> hd() |> elem(1) |> elem(0)
                  message = List.insert_at(conn.req_headers, 0, {model, type})
                  log_error_api(message, params["code"] <> "API POST - sales")

                  send_resp(conn, 500, "Sales to create. Please use the latest sales ID")
              end
          end
        else
          cond do
            user == nil ->
              message =
                List.insert_at(
                  conn.req_headers,
                  0,
                  {"authentication", "code and key doesnt match"}
                )

              log_error_api(message, "API POST")
              send_resp(conn, 400, "User not found.")

            true ->
              message = List.insert_at(conn.req_headers, 0, {"authentication", "unknown"})
              log_error_api(message, "API POST")
              send_resp(conn, 400, "user credentials are incorrect.")
          end
        end
    end
  end

  def update_dashboard_1(brand_id) do
    start_d = Date.utc_today()
    end_d = Date.utc_today()

    a =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: sp.salesid == s.salesid,
          left_join: b in BoatNoodle.BN.Branch,
          on: b.branchid == s.branchid,
          where:
            s.is_void == 0 and s.salesdate >= ^start_d and s.salesdate <= ^end_d and
              s.brand_id == ^brand_id and b.brand_id == ^brand_id and sp.brand_id == ^brand_id,
          group_by: [s.salesdate, b.branchname],
          select: %{
            salesdate: s.salesdate,
            pax: sum(s.pax),
            branchname: b.branchname,
            grand_total: sum(sp.grand_total),
            service_charge: sum(sp.service_charge),
            gst: sum(sp.gst_charge),
            after_disc: sum(sp.after_disc),
            transaction: count(s.salesid),
            sub_total: sum(sp.sub_total),
            rounding: sum(sp.rounding)
          }
        )
      )

    grp = a |> Enum.group_by(fn x -> x.salesdate end)

    year = a |> Enum.group_by(fn x -> x.salesdate.year end) |> Map.keys()

    grp_daily =
      for item <- year do
        sales = Enum.filter(a, fn x -> x.salesdate.year == item end)

        months = sales |> Enum.group_by(fn x -> x.salesdate.month end) |> Map.keys()

        for month <- months do
          sales = Enum.filter(a, fn x -> x.salesdate.month == month end)

          days = sales |> Enum.group_by(fn x -> x.salesdate end) |> Map.keys()

          for day <- days do
            data = Enum.filter(a, fn x -> x.salesdate == day end)

            total_grand_total =
              Enum.map(data, fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()

            total_after_disc =
              Enum.map(data, fn x -> Decimal.to_float(x.after_disc) end) |> Enum.sum()

            total_sub_total =
              Enum.map(data, fn x -> Decimal.to_float(x.sub_total) end) |> Enum.sum()

            total_sales =
              Enum.map(data, fn x -> Decimal.to_float(x.grand_total) end)
              |> Enum.sum()
              |> Float.round(2)

            total_rounding =
              Enum.map(data, fn x -> Decimal.to_float(x.rounding) end) |> Enum.sum()

            total_taxes =
              Enum.map(data, fn x -> Decimal.to_float(x.gst) end)
              |> Enum.sum()
              |> Float.round(2)

            total_service_charge =
              Enum.map(data, fn x -> Decimal.to_float(x.service_charge) end)
              |> Enum.sum()
              |> Float.round(2)

            total_discount =
              (total_grand_total -
                 (total_sub_total + total_taxes + total_service_charge + total_rounding))
              |> Float.round(2)

            total_transaction = Enum.map(data, fn x -> x.transaction end) |> Enum.sum()

            %{
              date: day,
              total_sales: total_sales - total_taxes,
              total_taxes: total_taxes,
              total_discount: total_discount,
              total_service_charge: total_service_charge,
              total_transaction: total_transaction
            }
          end
        end
      end
      |> List.flatten()

    group_data = a |> Enum.group_by(fn x -> x.branchname end) |> Map.keys()

    table_branch_daily_sales_sumary =
      for data <- group_data do
        data_all = a |> Enum.group_by(fn x -> x.branchname end)

        abc =
          for item <- data_all do
            name = item |> elem(0)
            item = item |> elem(1)

            if name == data do
              grand_total =
                Enum.map(item, fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()

              after_disc =
                Enum.map(item, fn x -> Decimal.to_float(x.after_disc) end) |> Enum.sum()

              sub_total = Enum.map(item, fn x -> Decimal.to_float(x.sub_total) end) |> Enum.sum()

              service_charge =
                Enum.map(item, fn x -> Decimal.to_float(x.service_charge) end) |> Enum.sum()

              gst = Enum.map(item, fn x -> Decimal.to_float(x.gst) end) |> Enum.sum()

              rounding = Enum.map(item, fn x -> Decimal.to_float(x.rounding) end) |> Enum.sum()

              nett_sale = grand_total - gst - rounding

              branchname = Enum.map(item, fn x -> x.branchname end) |> Enum.uniq() |> hd

              gross_sales =
                Enum.map(item, fn x -> Decimal.to_float(x.sub_total) end)
                |> Enum.sum()
                |> Float.round(2)
                |> Number.Delimit.number_to_delimited()

              service_charges =
                Enum.map(item, fn x -> Decimal.to_float(x.service_charge) end)
                |> Enum.sum()
                |> Float.round(2)
                |> Number.Delimit.number_to_delimited()

              taxes =
                Enum.map(item, fn x -> Decimal.to_float(x.gst) end)
                |> Enum.sum()
                |> Float.round(2)
                |> Number.Delimit.number_to_delimited()

              discounts =
                (grand_total - (sub_total + gst + service_charge + rounding))
                |> Number.Delimit.number_to_delimited()

              nett_sales =
                (grand_total - gst - rounding)
                |> Number.Delimit.number_to_delimited()

              roundings =
                Enum.map(item, fn x -> Decimal.to_float(x.rounding) end)
                |> Enum.sum()
                |> Float.round(2)
                |> Number.Delimit.number_to_delimited()

              total_sales = grand_total |> Float.round(2) |> Number.Delimit.number_to_delimited()

              pax = Enum.map(item, fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()

              transaction =
                Enum.map(item, fn x -> x.transaction end)
                |> Enum.sum()
                |> Number.Delimit.number_to_delimited()

              %{
                branchname: branchname,
                gross_sales: gross_sales,
                service_charge: service_charges,
                gst: taxes,
                discount: discounts,
                nett_sales: nett_sales,
                roundings: roundings,
                total_sales: total_sales,
                pax: pax,
                transaction: transaction
              }
            end
          end
      end
      |> List.flatten()
      |> Enum.reject(fn x -> x == nil end)

    grand_total = Enum.map(a, fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum()
    after_disc = Enum.map(a, fn x -> Decimal.to_float(x.after_disc) end) |> Enum.sum()
    sub_total = Enum.map(a, fn x -> Decimal.to_float(x.sub_total) end) |> Enum.sum()
    service_charge = Enum.map(a, fn x -> Decimal.to_float(x.service_charge) end) |> Enum.sum()
    gst = Enum.map(a, fn x -> Decimal.to_float(x.gst) end) |> Enum.sum()
    rounding = Enum.map(a, fn x -> Decimal.to_float(x.rounding) end) |> Enum.sum()
    pax = Enum.map(a, fn x -> Decimal.to_float(x.pax) end) |> Enum.sum()
    transaction = Enum.map(a, fn x -> x.transaction end) |> Enum.sum()
    discount = grand_total - (sub_total + gst + service_charge + rounding)

    d_nett_sales =
      (grand_total - gst - rounding + rounding) |> Number.Delimit.number_to_delimited()

    d_taxes =
      Enum.map(a, fn x -> Decimal.to_float(x.gst) end)
      |> Enum.sum()
      |> Number.Delimit.number_to_delimited()

    d_pax =
      Enum.map(a, fn x -> Decimal.to_float(x.pax) end)
      |> Enum.sum()
      |> Kernel.trunc()
      |> Number.Delimit.number_to_delimited()
      |> String.reverse()
      |> String.split_at(3)
      |> elem(1)
      |> String.reverse()

    d_transaction =
      Enum.map(a, fn x -> x.transaction end)
      |> Enum.sum()
      |> Kernel.trunc()
      |> Number.Delimit.number_to_delimited()
      |> String.reverse()
      |> String.split_at(3)
      |> elem(1)
      |> String.reverse()

    order_query =
      Repo.all(
        from(
          s in Sales,
          left_join: sm in SalesMaster,
          on: sm.salesid == s.salesid,
          left_join: b in BoatNoodle.BN.Branch,
          on: b.branchid == s.branchid,
          where:
            s.is_void == 0 and s.brand_id == ^brand_id and s.salesdate >= ^start_d and
              s.salesdate <= ^end_d,
          select: %{sales_details: sum(sm.qty)}
        )
      )

    d_order =
      order_query
      |> Enum.map(fn x -> Decimal.to_float(x.sales_details) end)
      |> Enum.sum()
      |> Kernel.trunc()
      |> Number.Delimit.number_to_delimited()
      |> String.reverse()
      |> String.split_at(3)
      |> elem(1)
      |> String.reverse()

    BoatNoodleWeb.Endpoint.broadcast("dashboard_channel:#{brand_id}", "dashboard_2", %{
      nett_sales: d_nett_sales,
      taxes: d_taxes,
      order: d_order,
      pax: d_pax,
      transaction: d_transaction
    })
  end

  def update_rest_status(brand_id, branch_id, params) do
    BoatNoodleWeb.Endpoint.broadcast("dashboard_channel:#{brand_id}", "branch_#{branch_id}", %{
      staff: params["current_user"],
      unsync: params["unsync"],
      versions: params["version"]
    })
  end

  def log_error_api(message, username) do
    # a list of single maps
    message =
      message
      |> Enum.reject(fn x -> elem(x, 1) == nil end)
      |> Enum.map(fn {k, v} -> %{k => v} end)
      |> Poison.encode!()

    a = ApiLog.changeset(%ApiLog{}, %{message: message, username: username})
    Repo.insert(a)

    messages =
      Repo.all(
        from(
          a in ApiLog,
          order_by: [desc: a.id],
          select: %{id: a.id, message: a.message, username: a.username, time: a.inserted_at},
          limit: 20
        )
      )

    topic = "user:1"
    event = "append_api_log"
    BoatNoodleWeb.Endpoint.broadcast(topic, event, %{messages: messages})
  end

  def log_api(message, username, branch_id, brand_id) do
    message =
      message
      |> Map.to_list()
      |> Enum.sort()
      |> Enum.reject(fn x -> elem(x, 1) == nil end)
      |> List.delete_at(0)
      |> List.delete_at(0)
      |> Enum.map(fn {k, v} -> %{Atom.to_string(k) => v} end)
      |> Poison.encode!()

    a =
      ApiLog.changeset(%ApiLog{}, %{
        message: message,
        username: username,
        brand_id: brand_id,
        branch_id: branch_id
      })

    Repo.insert(a)

    messages =
      Repo.all(
        from(
          a in ApiLog,
          order_by: [desc: a.id],
          select: %{id: a.id, message: a.message, username: a.username, time: a.inserted_at},
          limit: 20
        )
      )

    topic = "user:1"
    event = "append_api_log"
    BoatNoodleWeb.Endpoint.broadcast(topic, event, %{messages: messages})
  end

  def inform_sales_update(brand_id, branchid, created_at) do
    topic = "sales:#{brand_id}_#{branchid}"
    event = "update_sales_grandtotal"

    # start_date = created_at |> DateTime.to_date()
    # end_date = created_at |> DateTime.to_date() |> Timex.shift(days: 1)
    # # start_date = Date.new(2018, 6, 14) |> elem(1)
    # # end_date = Date.new(2018, 6, 15) |> elem(1)

    # outlet_sales =
    #   Repo.all(
    #     from(
    #       sp in BoatNoodle.BN.SalesPayment,
    #       left_join: s in BoatNoodle.BN.Sales,
    #       on: sp.salesid == s.salesid,
    #       left_join: b in BoatNoodle.BN.Branch,
    #       on: s.branchid == b.branchid,
    #       where:
    #         s.salesdate >= ^start_date and s.salesdate <= ^end_date and s.branchid == ^branchid and
    #           s.brand_id == ^brand_id,
    #       group_by: s.branchid,
    #       select: %{
    #         brand_id: s.brand_id,
    #         branch_id: s.branchid,
    #         branchname: b.branchname,
    #         sub_total: sum(sp.sub_total),
    #         service_charge: sum(sp.service_charge),
    #         gst_charge: sum(sp.gst_charge),
    #         after_disc: sum(sp.after_disc),
    #         grand_total: sum(sp.grand_total),
    #         rounding: sum(sp.rounding),
    #         pax: sum(s.pax)
    #       }
    #     )
    #   )

    # BoatNoodleWeb.Endpoint.broadcast(topic, event, hd(outlet_sales))
  end
end
