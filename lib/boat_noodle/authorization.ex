defmodule BoatNoodle.Authorization do
  use Phoenix.Controller, namespace: BoatNoodleWeb
  import Plug.Conn
  import Ecto.Query

  require IEx

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    if conn.private.plug_session["brand"] == nil do
      if conn.params["brand"] != nil do
        brand = BoatNoodle.Repo.get_by(BoatNoodle.BN.Brand, domain_name: conn.params["brand"])

        if brand != nil do
          brands = brand.domain_name
        else
          brands =
            BoatNoodle.Repo.all(from(b in BoatNoodle.BN.Brand, select: b.domain_name)) |> hd()
        end
      else
        brands =
          BoatNoodle.Repo.all(from(b in BoatNoodle.BN.Brand, select: b.domain_name)) |> hd()
      end
    else
      brands = conn.private.plug_session["brand"]
    end

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
end
