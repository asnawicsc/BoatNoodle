defmodule BoatNoodleWeb.PageController do
  use BoatNoodleWeb, :controller
  use Task
  import Ecto.Query
  require IEx

  def advance(conn, params) do
    users = Repo.all(from(u in User))
    brands = Repo.all(from(b in Brand))

    # html side have a radio button, indicate they can only appear at 1 brand at 1 time.
    render(conn, "advance.html", users: users, brands: brands)
  end

  def experiment2(conn, params) do
    date_range = Date.range(Date.from_iso8601!("2018-08-01"), Date.from_iso8601!("2018-08-31"))
    s_date = Date.from_iso8601!("2018-08-01")
    e_date = Date.from_iso8601!("2018-08-31")

    sm =
      for date <- date_range do
      end

    data =
      Repo.all(
        from(
          s in Sales,
          left_join: sm in SalesMaster,
          on: sm.salesid == s.salesid,
         left_join: is in ItemSubcat,
         on: is.subcatid == sm.itemid,
         left_join: ic in ItemCat,
         on: is.itemcatid == ic.itemcatid,
          where:
      
            s.brand_id == ^1 and s.salesdate >= ^s_date and s.salesdate <= ^e_date and
              s.branchid == ^"31" and ic.category_type == ^"COMBO" and is.brand_id == ^1 and ic.brand_id == ^1,

          select: %{
            salesid: s.salesid,
            salesdate: s.salesdate,
            itemname: sm.itemname,
            itemcode: sm.itemcode,
            itemid: sm.itemid,
            catid: is.itemcatid,
            category_type: ic.category_type,
            combo_id: sm.combo_id,
            qty: sm.qty
          }, limit: 300
        )
      )



    render(conn, "experiment2.html", data: data)


  end


def combo_qty_checker() do
  brand_id = String.to_integer(brand_id)

    is = Repo.get_by(ItemSubcat, brand_id: brand_id, subcatid: subcatid)


#check this combo has any selection?

items = Repo.all(from is in ItemSubcat, where: is.itemcatid == ^Integer.to_string(is.subcatid) and is.brand_id == ^brand_id)

combo_details = Repo.all(from cd in ComboDetails, where: cd.combo_id == ^Integer.to_string(is.subcatid), group_by: [cd.menu_cat_id], select: %{menu_cat_id: cd.menu_cat_id, qty: cd.combo_item_qty}  ) 

total_qty_in_combo=
if combo_details != [] do
  Enum.map(combo_details, fn x -> x.qty end) |> Enum.sum()
  else
    0
end

qty = qty |> String.to_integer()

sd = Repo.all(from sm in SalesMaster, where:  sm.salesid == ^salesid and sm.is_void == ^0) 
|> Enum.filter(fn x -> x.combo_id == String.to_integer(subcatid) end)  
|> Enum.map(fn x -> x.qty end)
 |> Enum.sum()


res = total_qty_in_combo * qty == sd
end

  def experiment(conn, params) do
    date_range = Date.range(Date.from_iso8601!("2018-08-01"), Date.from_iso8601!("2018-08-31"))
    s_date = Date.from_iso8601!("2018-08-01")
    e_date = Date.from_iso8601!("2018-08-31")

    sm =
      for date <- date_range do
      end

    data =
      Repo.all(
        from(
          s in Sales,
          left_join: sm in SalesMaster,
          on: sm.salesid == s.salesid,
          where:
            s.brand_id == ^1 and s.salesdate >= ^s_date and s.salesdate <= ^e_date and
              s.branchid == ^"31" and sm.combo_id != 0,
          select: %{
            salesid: s.salesid,
            salesdate: s.salesdate,
            itemname: sm.itemname,
            itemcode: sm.itemcode,
            order_price: sm.order_price,
            qty: sm.qty,
            combo_id: sm.combo_id
          }, limit: 1000
        )
      )

    # combo_ids =
    #   Repo.all(
    #     from(
    #       s in Sales,
    #       left_join: sm in SalesMaster,
    #       on: sm.salesid == s.salesid,
    #       where:
    #         s.brand_id == ^1 and s.salesdate >= ^s_date and s.salesdate <= ^e_date and
    #           s.branchid == ^"2" and sm.combo_id != 0,
    #       select: sm.combo_id
    #     )
    #   )
    #   |> Enum.uniq()

    render(conn, "experiment.html", data: data)


  end

  defp csv_content(branchid) do


    date_range = Date.range(Date.from_iso8601!("2018-08-01"), Date.from_iso8601!("2018-08-31"))
    s_date = Date.from_iso8601!("2018-08-01")
    e_date = Date.from_iso8601!("2018-08-31")

    sm =
      for date <- date_range do
      end

    data =
      Repo.all(
        from(
          s in Sales,
          left_join: sm in SalesMaster,
          on: sm.salesid == s.salesid,
          where:
            s.brand_id == ^1 and s.salesdate >= ^s_date and s.salesdate <= ^e_date and
              s.branchid == ^"31" and sm.combo_id != 0,
          select: %{
            salesid: s.salesid,
            salesdate: s.salesdate,
            itemname: sm.itemname,
            itemcode: sm.itemcode,
            order_price: sm.order_price,
            qty: sm.qty,
            combo_id: sm.combo_id
          }
        )
      )
      |> Enum.map(fn x ->
        %{
          salesdate: x.salesdate,
          itemcode: code_combo(x.itemname),
          itemname: x.itemname,
          unit_price: find_combo_unit_price(code_combo(x.itemname), x.combo_id, "1"),
          qty: x.qty
        }
      end)

    dates = data |> Enum.group_by(fn x -> x.salesdate end) |> Map.keys()
    items = data |> Enum.group_by(fn x -> x.itemcode end) |> Map.keys()

    data2 =
      for date <- dates do
        for item <- items do
          bulk_data =
            Enum.filter(data, fn x -> x.salesdate == date end)
            |> Enum.filter(fn x -> x.itemcode == item end)

          if bulk_data != [] do
            qty = bulk_data |> Enum.map(fn x -> x.qty end) |> Enum.sum()

            total_price =
              bulk_data |> Enum.map(fn x -> x.unit_price end) |> Enum.sum() |> Decimal.new()

            itemname = bulk_data |> Enum.map(fn x -> x.itemname end) |> Enum.uniq()

            itemname =
              if itemname != [] do
                hd(itemname)
              else
                "EMPTY"
              end

            {
              Date.to_string(date),
              item,
              itemname,
              Integer.to_string(qty),
              Decimal.to_string(total_price)
            }
          end
        end
        |> Enum.reject(fn x -> x == nil end)
      end


    csv_header = [
      'salesdate',
      'itemcode',
      'itemname',
      'qty',
      'total_price'
    ]

    data = data |> List.flatten() |> Enum.map(fn x -> Tuple.to_list(x) end)

csv =
    List.insert_at(data, 0, csv_header)
    |> CSV.encode()
    |> Enum.to_list()
    |> to_string



        conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"Combo Item Analysis.csv\""
    )
    |> send_resp(200, csv)
  end

  def code_combo(name) do
    String.split(name, "") |> Enum.take(4) |> Enum.join()
  end

  def find_combo_unit_price(itemcode, comboid, brand_id) do
    cd =
      Repo.get_by(
        ComboDetails,
        brand_id: String.to_integer(brand_id),
        combo_item_code: itemcode,
        combo_id: comboid
      )

    if cd != nil do
      Decimal.to_float(cd.unit_price)
    else
      0
    end
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> put_flash(:info, "Logout successfully")
    |> redirect(to: page_path(conn, :report_login))
  end

  def authenticate_login(conn, %{"username" => username, "password" => password}) do
    user = Repo.get_by(User, username: username)

    if user != nil do
      p2 = String.replace(user.password, "$2y", "$2b")

      if Comeonin.Bcrypt.checkpw(password, p2) do
        brand = Repo.get(Brand, user.brand_id)

        # if user.read_report_only == 0 do
        conn
        |> put_session(:user_id, user.id)
        |> put_session(:brand, brand.domain_name)
        |> put_session(:brand_id, brand.id)
        |> redirect(to: page_path(conn, :index2, brand.domain_name))

        # else
        #   conn
        #   |> put_session(:user_id, user.id)
        #   |> redirect(to: page_path(conn, :report_index))
        # end
      else
        conn
        |> put_flash(:error, "Wrong password!")
        |> redirect(to: page_path(conn, :report_login))
      end
    else
      conn
      |> put_flash(:error, "User not found")
      |> redirect(to: page_path(conn, :report_login))
    end
  end

  def report_login(conn, params) do
    render(conn, "login.html", layout: {BoatNoodleWeb.LayoutView, "report_layout.html"})
  end

  def report_index(conn, params) do
    branches =
      Repo.all(
        from(
          s in BoatNoodle.BN.UserBranchAccess,
          left_join: g in BoatNoodle.BN.Branch,
          on: s.branchid == g.branchid,
          where: s.userid == ^conn.private.plug_session["user_id"],
          select: %{branchid: s.branchid, branchname: g.branchname},
          order_by: g.branchname
        )
      )

    render(conn, "dashboard.html", branches: branches)
  end

  def webhook_key(conn, params) do
    bb = Repo.all(from(b in Branch, where: b.branchcode == ^params["code"]))

    if bb != [] do
      branch = hd(bb)

      api_key =
        Comeonin.Bcrypt.hashpwsalt(branch.branchname) |> String.replace("$2b", "$2y")
        |> Base.url_encode64()

      cg = Branch.changeset(branch, %{api_key: api_key})
      map = %{key: api_key} |> Poison.encode!()

      case Repo.update(cg) do
        {:ok, bb} ->
          send_resp(conn, 200, map)

        {:error, cg} ->
          send_resp(conn, 500, " not ok")
      end
    else
      send_resp(conn, 500, " not ok")
    end
  end

  def get_brands(conn, _params) do
    brands = Repo.all(Brand) |> Enum.map(fn x -> %{name: x.domain_name} end) |> Poison.encode!()
    send_resp(conn, 200, brands)
  end

  def index(conn, _params) do
    brands = Repo.all(Brand) |> hd()

    conn
    |> redirect(to: user_path(conn, :login, brands.domain_name))
  end

  def index2(conn, _params) do
    branches =
      Repo.all(
        from(
          s in BoatNoodle.BN.UserBranchAccess,
          left_join: g in BoatNoodle.BN.Branch,
          on: s.branchid == g.branchid,
          where:
            s.brand_id == ^BN.get_brand_id(conn) and g.brand_id == ^BN.get_brand_id(conn) and
              s.userid == ^conn.private.plug_session["user_id"],
          select: %{branchid: s.branchid, branchname: g.branchname},
          order_by: g.branchname
        )
      )

    render(conn, "dashboard.html", branches: branches)
  end

  def no_page_found(conn, _params) do
    conn
    |> put_flash(:error, "No page found")
    |> redirect(to: page_path(conn, :index2, BN.get_domain(conn)))
  end
end
