defmodule BoatNoodleWeb.ApiController do
  use BoatNoodleWeb, :controller
  use Task
  import Ecto.Query
  require IEx

  def webhook_get(conn, params) do
    cond do
      params["key"] == nil ->
        send_resp(conn, 400, "please include key .")

      params["brand"] == nil ->
        send_resp(conn, 400, "please include brand name.")

      params["branch_id"] == nil ->
        send_resp(conn, 400, "please include branch id.")

      params["fields"] == nil ->
        send_resp(conn, 400, "please include sales id in field.")

      params["branch_id"] != nil and params["branch_id"] != nil and params["key"] != nil and
          params["code"] != nil ->
        brb = Repo.get_by(Branch, branchcode: params["code"], api_key: params["key"])

        if brb != nil do
          branch_id = params["branch_id"]
          brand = params["brand"]
          bb = Repo.get_by(Brand, domain_name: brand)
          branch = Repo.get_by(Branch, branchid: branch_id, brand_id: bb.id)

          if branch != nil do
            case params["fields"] do
              "sales_id" ->
                get_scope_sales_id(conn, branch.branchid, bb.id, params["code"])

              "printers" ->
                get_scope_branch_printer(conn, branch.branchid, bb.id, params["code"])

              "items" ->
                get_scope_branch_items(
                  conn,
                  branch.branchid,
                  bb.id,
                  params["code"],
                  branch.menu_catalog
                )

              "branch_details" ->
                get_scope_branch_details(conn, branch)

              "vouchers" ->
                get_scope_vouchers(conn, branch.branchid, bb.id, params["code"])

              "item_remarks" ->
                get_scope_item_remarks(conn, branch.branchid, bb.id, params["code"])

              "staffs" ->
                get_scope_staffs(conn, branch.branchid, bb.id, params["code"])

              "payment_types" ->
                get_scope_payment_types(conn, branch.branchid, bb.id, params["code"])
              _ ->
                message =
                  List.insert_at(conn.req_headers, 0, {"fields", "not within defined fields"})

                log_error_api(message, "API GET")
                send_resp(conn, 500, "request not available. \n")
            end
          else
            message = List.insert_at(conn.req_headers, 0, {"branch", "db cant find branch"})
            log_error_api(message, "API GET")
            send_resp(conn, 400, "branch doesnt exist. \n")
          end
        else
          message = List.insert_at(conn.req_headers, 0, {"authentication", "wrong combination"})
          log_error_api(message, "API GET")

          send_resp(conn, 500, "branch doesnt exist. \n")
        end
    end
  end


  def get_scope_payment_types(conn, branch_id, brand_id, branchcode) do
    payment_types = Repo.all(from x in PaymentType, where: x.brand_id == ^brand_id, select: %{
      is_visible: x.is_visible,
      is_default: x.is_default,
      is_payment_code: x.is_payment_code,
      is_card_no: x.is_card_no,
      payment_type_code: x.payment_type_code,
      payment_type_id: x.payment_type_id,
      payment_type_name: x.payment_type_name


     })
      |> Poison.encode!()

    message = List.insert_at(conn.req_headers, 0, {"payment_types", "payment_types"})
    log_error_api(message, "API GET - payment_types")
    send_resp(conn, 200, payment_types)
  end


  def get_scope_staffs(conn, branch_id, brand_id, branchcode) do
    staffs = Repo.all(from v in Staff, where: v.brand_id == ^brand_id, select: %{
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


     })
      |> Poison.encode!()

    message = List.insert_at(conn.req_headers, 0, {"staffs", "staffs"})
    log_error_api(message, "API GET - staffs")
    send_resp(conn, 200, staffs)
  end

  def get_scope_item_remarks(conn, branch_id, brand_id, branchcode) do
    item_remarks = Repo.all(from v in Remark, where: v.brand_id == ^brand_id, select: %{
      itemsremarkid: v.itemsremarkid, 
      remark: v.remark,
      target_cat: v.target_cat,
      target_item: v.target_item


     })
      |> Poison.encode!()

    message = List.insert_at(conn.req_headers, 0, {"item remarks", "item remarks"})
    log_error_api(message, "API GET - item remarks")
    send_resp(conn, 200, item_remarks)
  end


  def get_scope_vouchers(conn, branch_id, brand_id, branchcode) do
    vouchers = Repo.all(from v in Voucher, where: v.is_used == ^false, select: %{id: v.id, code_number: v.code_number, discount_name: v.discount_name, is_used: v.is_used })
      |> Poison.encode!()

    message = List.insert_at(conn.req_headers, 0, {"vouchers", "vouchers"})
    log_error_api(message, "API GET - vouchers")
    send_resp(conn, 200, vouchers)
  end

  def get_scope_branch_details(conn, branch) do
    b = branch

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
        report_class: b.report_class
      }
      |> Poison.encode!()

    message = List.insert_at(conn.req_headers, 0, {"branch_details", "branch_details"})
    log_error_api(message, "API GET - branch_details")
    send_resp(conn, 200, branch_details)
  end

  def get_scope_branch_items(conn, branch_id, brand_id, branchcode, menu_cat_id) do
    menu_catalog = Repo.get_by(MenuCatalog, id: menu_cat_id, brand_id: brand_id)

    subcat_ids = menu_catalog.items |> String.split(",") |> Enum.reject(fn x -> x == "" end)
    combo_ids = menu_catalog.combo_items |> String.split(",") |> Enum.reject(fn x -> x == "" end)

    subcats =
      Repo.all(from(s in ItemSubcat, where: s.subcatid in ^subcat_ids))
      |> Enum.map(fn x ->
        %{
          brand_id: x.brand_id,
          subcatid: x.subcatid,
          itemcatid: x.itemcatid,
          itemname: x.itemname,
          itemcode: x.itemcode,
          product_code: x.product_code,
          price_code: x.price_code,
          part_code: x.part_code,
          itemdesc: x.itemdesc,
          itemprice: x.itemprice,
          itemimage: x.itemimage,
          is_categorize: x.is_categorize,
          is_activate: x.is_activate,
          is_comboitem: x.is_comboitem,
          is_default_combo: x.is_default_combo,
          is_delete: x.is_delete,
          enable_disc: x.enable_disc,
          include_spend: x.include_spend,
          is_print: x.is_print
        }
      end)

    combos =
      Repo.all(
        from(
          c in ComboDetails,
          where: c.id in ^combo_ids,
          select: %{
            brand_id: c.brand_id,
            id: c.id,
            menu_cat_id: c.menu_cat_id,
            combo_id: c.combo_id,
            combo_qty: c.combo_qty,
            combo_item_id: c.combo_item_id,
            combo_item_name: c.combo_item_name,
            combo_item_code: c.combo_item_code,
            combo_item_qty: c.combo_item_qty,
            update_qty: c.update_qty,
            unit_price: c.unit_price,
            top_up: c.top_up
          }
        )
      )

    json_map = %{combos: combos, subcats: subcats} |> Poison.encode!()

    if menu_catalog != nil do
      message = List.insert_at(conn.req_headers, 0, {"menu_catalog", "menu_catalog"})
      log_error_api(message, "API GET - menu_catalog items")
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
      |> Poison.encode!()

    message = List.insert_at(conn.req_headers, 0, {"printer", "printer"})
    log_error_api(message, "API GET - printer")
    send_resp(conn, 200, printers)
  end

  def get_scope_sales_id(conn, branch_id, brand_id, branchcode) do
    invoiceno =
      Repo.all(
        from(
          s in Sales,
          where: s.branchid == ^Integer.to_string(branch_id) and s.brand_id == ^brand_id,
          select: %{
            invoiceno: s.invoiceno
          },
          order_by: [s.invoiceno]
        )
      )
      |> Enum.map(fn x -> x.invoiceno end)
      |> Enum.map(fn x -> String.to_integer(x) end)
      |> Enum.max()

    id =
      (invoiceno + 1)
      |> Integer.to_string()

    salesid = branchcode <> "" <> id
    json_map = %{salesid: salesid} |> Poison.encode!()

    message = List.insert_at(conn.req_headers, 0, {"sales id", "#{salesid}"})
    log_error_api(message, "API GET - sales")
    send_resp(conn, 200, json_map)
  end

  def webhook_post(conn, params) do
    a_list = params["details"]
    brand = params["brand"]
    bb = Repo.get_by(Brand, domain_name: brand)

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

          sales_payment_params =
            for {key, val} <- params["payment"], into: %{}, do: {String.to_atom(key), val}

          if Map.get(sales_params, :salesid) == nil do
            invoiceno =
              Repo.all(
                from(
                  s in Sales,
                  where: s.branchid == ^sales_params.branchid,
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
                  where: b.branchid == ^sales_params.branchid,
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
            sales_params = Map.put(sales_params, :invoiceno, id)
          end

          sales_exist = Repo.get_by(Sales, salesid: sales_params.salesid)

          cond do
            sales_exist != nil ->
              message = List.insert_at(conn.req_headers, 0, {"sales id", "already exist"})
              log_error_api(message, "API POST - sales")
              send_resp(conn, 501, "Sales id exist.")

            sales_exist == nil ->
              case BN.create_sales(sales_params) do
                {:ok, sales} ->
                  sales_payment_params = Map.put(sales_payment_params, :salesid, sales.salesid)

                  Task.start_link(__MODULE__, :log_api, [IO.inspect(sales), params["code"]])

                  sd =
                    for sales_master_params <- sales_master_params_list do
                      sales_master_params = Map.put(sales_master_params, :salesid, sales.salesid)

                      case BN.create_sales_master(sales_master_params) do
                        {:ok, sales_master} ->
                          Task.start_link(__MODULE__, :log_api, [
                            IO.inspect(sales_master),
                            params["code"]
                          ])

                          :ok

                        {:error, %Ecto.Changeset{} = changeset} ->
                          model = changeset.errors |> hd() |> elem(0) |> Atom.to_string()
                          type = changeset.errors |> hd() |> elem(1) |> elem(0)
                          message = List.insert_at(conn.req_headers, 0, {model, type})
                          log_error_api(message, "API POST - sales details")
                          :error
                      end
                    end

                  if sd |> Enum.any?(fn x -> x == :error end) do
                    Repo.delete_all(
                      from(
                        s in SalesMaster,
                        where: s.salesid == ^sales.salesid and s.brand_id == ^bb.id
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
                    case BN.create_sales_payment(sales_payment_params) do
                      {:ok, sales_payment} ->
                        Task.start_link(__MODULE__, :log_api, [
                          IO.inspect(sales_payment),
                          params["code"]
                        ])

                        Task.start_link(__MODULE__, :inform_sales_update, [
                          sales.brand_id,
                          sales.branchid,
                          sales.created_at
                        ])

                        send_resp(conn, 200, "Sales #{sales.salesid} create successfully.")

                      {:error, %Ecto.Changeset{} = changeset} ->
                        model = changeset.errors |> hd() |> elem(0) |> Atom.to_string()
                        type = changeset.errors |> hd() |> elem(1) |> elem(0)
                        message = List.insert_at(conn.req_headers, 0, {model, type})
                        log_error_api(message, "API POST - sales payment")
                        send_resp(conn, 500, "Sales master failed to create.")
                        send_resp(conn, 500, "Sales payment failed to create.")
                    end
                  end

                {:error, %Ecto.Changeset{} = changeset} ->
                  model = changeset.errors |> hd() |> elem(0) |> Atom.to_string()
                  type = changeset.errors |> hd() |> elem(1) |> elem(0)
                  message = List.insert_at(conn.req_headers, 0, {model, type})
                  log_error_api(message, "API POST - sales")

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

  def log_api(message, username) do
    message =
      message
      |> Map.to_list()
      |> Enum.reject(fn x -> elem(x, 1) == nil end)
      |> List.delete_at(0)
      |> List.delete_at(0)
      |> Enum.map(fn {k, v} -> %{Atom.to_string(k) => v} end)
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

  def inform_sales_update(brand_id, branchid, created_at) do
    topic = "sales:#{brand_id}_#{branchid}"
    event = "update_sales_grandtotal"

    # start_date = created_at |> DateTime.to_date()
    # end_date = created_at |> DateTime.to_date() |> Timex.shift(days: 1)
    start_date = Date.new(2018, 6, 14) |> elem(1)
    end_date = Date.new(2018, 6, 15) |> elem(1)

    outlet_sales =
      Repo.all(
        from(
          sp in BoatNoodle.BN.SalesPayment,
          left_join: s in BoatNoodle.BN.Sales,
          on: sp.salesid == s.salesid,
          left_join: b in BoatNoodle.BN.Branch,
          on: s.branchid == b.branchid,
          where:
            s.salesdate >= ^start_date and s.salesdate <= ^end_date and s.branchid == ^branchid and
              s.brand_id == ^brand_id,
          group_by: s.branchid,
          select: %{
            brand_id: s.brand_id,
            branch_id: s.branchid,
            branchname: b.branchname,
            sub_total: sum(sp.sub_total),
            service_charge: sum(sp.service_charge),
            gst_charge: sum(sp.gst_charge),
            after_disc: sum(sp.after_disc),
            grand_total: sum(sp.grand_total),
            rounding: sum(sp.rounding),
            pax: sum(s.pax)
          }
        )
      )

    BoatNoodleWeb.Endpoint.broadcast(topic, event, hd(outlet_sales))
  end
end
