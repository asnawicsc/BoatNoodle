defmodule BoatNoodle.Authorization do
  use Phoenix.Controller, namespace: BoatNoodleWeb
  import Plug.Conn
  import Ecto.Query

  require IEx

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    if conn.request_path == "/" do
      conn
    else
      # all these will return a brand name in the url path
      domain_name =
        if check_plug_session_has_brand(conn) do
          if conn.private.plug_session["brand"] != conn.params["brand"] do
            ""
          else
            conn.private.plug_session["brand"]
          end
        else
          # then it will go by the url provided brand name
          if conn.params["brand"] != nil do
            brand = BoatNoodle.Repo.get_by(BoatNoodle.BN.Brand, domain_name: conn.params["brand"])

            if brand != nil do
              brand.domain_name
            else
              ""
            end
          else
            ""
          end
        end

      if domain_name != "" do
        route_user_brand(conn, domain_name)
      else
        route_user(conn)
      end

      if conn.private.plug_session["user_id"] == nil do
        conn
      else
        if authorize?(conn, domain_name) do
          conn
          |> put_flash(:error, "Unauthorized")
          |> redirect(to: "/#{domain_name}")
          |> halt
        else
          conn
        end
      end
    end
  end

  def check_plug_session_has_brand(conn) do
    conn.private.plug_session["brand"] != nil
  end

  def route_user_brand(conn, brands) do
    if conn.private.plug_session["user_id"] == nil do
      if conn.request_path == "/#{brands}/login" or
           conn.request_path == "/#{brands}/authenticate_login" or
           conn.request_path == "/#{brands}/forget_password" or
           conn.request_path == "/#{brands}/forget_password_email" or
           conn.request_path == "/#{brands}/api/sales" or
           conn.request_path == "/#{brands}/internal_api" do
        conn
      else
        conn
        |> put_flash(:error, "Please login first!")
        |> redirect(to: "/login")
        |> halt
      end
    else
      conn
    end
  end

  def route_user(conn) do
    if conn.private.plug_session["user_id"] == nil do
      if conn.request_path == "/" or conn.request_path == "/authenticate_login" or
           conn.request_path == "/forget_password" or conn.request_path == "/logout" or
           conn.request_path == "/forget_password_email" or conn.request_path == "/api/sales" do
        conn
      else
        conn
        |> delete_session(:user_id)
        |> delete_session(:brand_id)
        |> delete_session(:brand)
        |> redirect(to: "/")
        |> halt
      end
    else
      if conn.private.plug_session["brand"] == conn.params["brand"] do
        conn
      else
        conn
        |> delete_session(:user_id)
        |> delete_session(:brand_id)
        |> delete_session(:brand)
        |> redirect(to: "/")
        |> halt
      end
    end
  end

  def authorize?(conn, brands) do
    user = BoatNoodle.Repo.get_by(BoatNoodle.BN.User, id: conn.private.plug_session["user_id"])

    admin_menus =
      BoatNoodle.Repo.all(
        from(
          b in BoatNoodle.BN.UnauthorizeMenu,
          left_join: g in BoatNoodle.BN.User,
          on: b.role_id == g.roleid,
          left_join: c in BoatNoodle.BN.UserRole,
          on: g.roleid == c.roleid,
          where: g.id == ^user.id and b.active == 1
        )
      )
      |> Enum.map(fn x -> x.url end)
      |> Enum.map(fn x -> String.replace(x, "/", "") end)

    path = conn.path_info |> tl

    Enum.any?(admin_menus, fn x -> Enum.any?(path, fn y -> x == y end) end)
    # status = conn.path_info |> List.last()

    # if status == "edits" or status == "edit" do
    #   admin_menus = admin_menus |> Enum.map(fn x -> String.replace(x, "/", "") end)

    #   if Enum.any?(admin_menus, fn x -> x == path end) do
    #     conn
    #     |> put_flash(:error, "Unauthorized")
    #     |> redirect(to: "/#{brands}")
    #     |> halt
    #   end
    # else
    #   if Enum.any?(admin_menus, fn x -> x == conn.request_path end) do
    #     conn
    #     |> put_flash(:error, "Unauthorized")
    #     |> redirect(to: "/#{brands}")
    #     |> halt
    #   end
    # end
  end
end
