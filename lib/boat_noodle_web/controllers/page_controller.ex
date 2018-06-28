defmodule BoatNoodleWeb.PageController do
  use BoatNoodleWeb, :controller
  use Task
  import Ecto.Query
  require IEx

  def authenticate_login(conn, %{"username" => username, "password" => password}) do
    user = Repo.get_by(User, username: username)

    if user != nil do
      p2 = String.replace(user.password, "$2y", "$2b")

      if Comeonin.Bcrypt.checkpw(password, p2) do
        conn
        |> put_session(:user_id, user.id)
        |> redirect(to: page_path(conn, :report_index))
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
    render(conn, "login.html")
  end

  def report_index(conn, params) do
    brands = Repo.all(from(b in Brand, select: %{name: b.domain_name, id: b.id}))

    render(conn, "index.html", brands: brands)
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
    render(conn, "dashboard.html")
  end

  def webhook_get(conn, params) do
   
    cond do
      params["key"]  == nil ->
        send_resp(conn, 400, "please include key .")
  
      params["brand"] == nil ->
        send_resp(conn, 400, "please include brand name.")

      params["branch_id"] == nil ->
        send_resp(conn, 400, "please include branch id.")

      params["fields"] == nil ->
        send_resp(conn, 400, "please include sales id in field.")

      params["branch_id"] != nil and params["branch_id"] != nil and params["key"] != nil and params["code"] != nil ->
        brb = Repo.get_by(Branch, branchcode: params["code"] , api_key: params["key"] )
        if brb != nil do
            branch_id = params["branch_id"]
            brand = params["brand"]
            fields = params["sales_id"]
            bb = Repo.get_by(Brand, domain_name: brand)
            branch = Repo.get_by(Branch, branchid: branch_id, brand_id: bb.id)

            if branch != nil do
              invoiceno =
                Repo.all(
                  from(
                    s in Sales,
                    where: s.branchid == ^branch_id and s.brand_id == ^bb.id,
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

              salesid = branch.branchcode <> "" <> id
              json_map = %{salesid: salesid} |> Poison.encode!()

               message = List.insert_at(conn.req_headers, 0, {"sales id", "#{salesid}"})
                log_error_api(message, "API GET - sales")
              send_resp(conn, 200, json_map)
            else
            message = List.insert_at(conn.req_headers, 0, {"branch", "db cant find branch"})
            log_error_api(message, "API GET")
              send_resp(conn, 400, "branch doesnt exist.")
            end
          else 
            message = List.insert_at(conn.req_headers, 0, {"authentication", "wrong combination"})
            log_error_api(message, "API GET")
       
            send_resp(conn, 500, "branch doesnt exist.")
        end
    end
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
      params["code"] == nil  ->
        message = List.insert_at(conn.req_headers, 0, {"branch code", "code value is empty"})
        log_error_api(message, "API POST")
        send_resp(conn, 400, "please include code .")
      true ->
        user = Repo.get_by(Branch, branchcode: params["code"] , api_key: params["key"] )

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
                            Task.start_link(__MODULE__, :log_api, [IO.inspect(sales_master), params["code"]])

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

                      message = List.insert_at(conn.req_headers, 0, {"sales details", "one of it has issues, the created sales and other sales details will be deleted."})
                      log_error_api(message, "API POST - sales details")
                      send_resp(conn, 500, "Sales master failed to create.")
                    else
                      case BN.create_sales_payment(sales_payment_params) do
                        {:ok, sales_payment} ->
                          Task.start_link(__MODULE__, :log_api, [IO.inspect(sales_payment), params["code"]])

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
              message = List.insert_at(conn.req_headers, 0, {"authentication", "code and key doesnt match"})
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

  def no_page_found(conn, _params) do
    conn
    |> put_flash(:error, "No page found")
    |> redirect(to: page_path(conn, :index, BN.get_domain(conn)))
  end
end
