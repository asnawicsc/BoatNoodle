defmodule BoatNoodleWeb.PageController do
  use BoatNoodleWeb, :controller
  use Task
  import Ecto.Query
  require IEx

  def experiment(conn, params) do
        render(conn, "experiment.html")
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

  def webhook_key(conn, params) do


    bb = Repo.all(from b in Branch, where: b.branchcode ==^ params["code"])


    if bb != [] do
      branch = hd(bb)
 

        api_key = Comeonin.Bcrypt.hashpwsalt(branch.branchname) |> String.replace("$2b", "$2y") |> Base.url_encode64()
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

  branches = Repo.all(from(s in BoatNoodle.BN.Branch, where: s.brand_id==^BN.get_brand_id(conn)))
 
    render(conn, "dashboard.html",branches: branches)
  end


  def no_page_found(conn, _params) do
    conn
    |> put_flash(:error, "No page found")
    |> redirect(to: page_path(conn, :index, BN.get_domain(conn)))
  end
end
