defmodule BoatNoodle.Authorization do
  use Phoenix.Controller, namespace: BoatNoodleWeb
  import Plug.Conn

  require IEx

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    if conn.private.plug_session["user_id"] == nil do
      if conn.request_path == "/login" or conn.request_path == "/authenticate_login" or
           conn.request_path == "/forget_password" or
           conn.request_path == "/forget_password_email" do
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
end
