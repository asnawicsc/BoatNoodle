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

    if conn.private.plug_session["user_id"] == nil do 
        conn
    else 
        if authorize?(conn, brands) do
          conn
          |> put_flash(:error, "Unauthorized")
          |> redirect(to: "/#{brands}")
          |> halt
        else
          conn
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


  def authorize?(conn,brands) do

   user =BoatNoodle.Repo.get_by(BoatNoodle.BN.User, id: conn.private.plug_session["user_id"])
    
     admin_menus = BoatNoodle.Repo.all(from b in BoatNoodle.BN.UnauthorizeMenu,
     left_join: g in BoatNoodle.BN.User, on: b.role_id==g.roleid,
     left_join: c in BoatNoodle.BN.UserRole, on: g.roleid==c.roleid,
      where: g.id == ^user.id and b.active==1)|> Enum.map(fn x -> x.url end)

      path=conn.path_info|>List.delete_at(2)|>List.to_string
      status=conn.path_info|>List.last

      if status == "edit"  do

        admin_menus = admin_menus |> Enum.map(fn x -> String.replace(x, "/", "") end)
         if Enum.any?(admin_menus, fn x -> x == path end) do
          conn
              |> put_flash(:error, "Unauthorized")
              |> redirect(to: "/#{brands}")
              |> halt 
         end
      else

         if Enum.any?(admin_menus, fn x -> x == conn.request_path end) do
          conn
              |> put_flash(:error, "Unauthorized")
              |> redirect(to: "/#{brands}")
              |> halt 
         end
     end
  end
end