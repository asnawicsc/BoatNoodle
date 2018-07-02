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
      if conn.private.plug_session["brand"] == nil do
        if conn.params["brand"] != nil do
          brand = BoatNoodle.Repo.get_by(BoatNoodle.BN.Brand, domain_name: conn.params["brand"])

          if brand != nil do
            brands = brand.domain_name
          else
            brands = ""
          end
        else
          brands = ""
        end
      else
        if conn.private.plug_session["brand"] != conn.params["brand"] do
          brands = ""
          else
          brands = conn.private.plug_session["brand"]
        end
      end

      if brands != "" do
        route_user_brand(conn, brands)
        else 
          route_user(conn)
      end

    end
  end

  def route_user_brand(conn, brands) do
      if conn.private.plug_session["user_id"] == nil do
        if conn.request_path == "/#{brands}/login" or
             conn.request_path == "/#{brands}/authenticate_login" or
             conn.request_path == "/#{brands}/forget_password" or
             conn.request_path == "/#{brands}/forget_password_email" or
             conn.request_path == "/#{brands}/api/sales" do
          conn
        else
          conn
          |> put_flash(:error, "Please login first!")
          |> redirect(to: "/#{brands}/login")
          |> halt
        end
      else
        conn
      end
  end

  def route_user(conn) do
      if conn.private.plug_session["user_id"] == nil do
        if conn.request_path == "/" or
             conn.request_path == "/authenticate_login" or
             conn.request_path == "/forget_password" or
             conn.request_path == "/logout" or
             conn.request_path == "/forget_password_email" or
             conn.request_path == "/api/sales" do
          conn
        else
          conn
          |> put_flash(:error, "Please login first!")
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
          |> put_flash(:error, "Please login first!")
          |> redirect(to: "/")
          |> halt
        end
        

      end
  end
end
