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

  def experiment(conn, params) do
    tags = Repo.all(from(t in Tag, where: t.brand_id == ^1 and t.branch_id == ^31))
    # target_branch_id = 43

    for tag <- tags do
      subcat_ids = tag.subcat_ids |> String.split(",") |> Enum.reject(fn x -> x == "" end)

      for subcat_id <- subcat_ids do
        subcat = Repo.get_by(ItemSubcat, subcatid: subcat_id, brand_id: 1)

        {:ok, subcat} =
          ItemSubcat.changeset(subcat, %{tagdesc: tag.tagdesc, printer: tag.printer}, 0, "Update")
          |> Repo.update()

        similar_items = Repo.all(from(i in ItemSubcat, where: i.itemname == ^subcat.itemname))

        for item_subcat <- similar_items do
          ItemSubcat.changeset(
            item_subcat,
            %{tagdesc: tag.tagdesc, printer: tag.printer},
            0,
            "Update"
          )
          |> Repo.update()
        end
      end

      # each branch has a menu_catalog, each catalog has its own uniq subcat it...

      # existing subcat_id.. find the item_subcat..

      # match with target branch menu catalog subcat ids
    end

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
        brand = Repo.get(Brand, user.brand_id)

        conn
        |> put_session(:user_id, user.id)
        |> put_session(:brand, brand.domain_name)
        |> put_session(:brand_id, brand.id)
        |> redirect(to: page_path(conn, :index2, brand.domain_name))
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
    brands = Repo.all(from(b in Brand, select: %{name: b.domain_name, id: b.id}))

    render(conn, "index.html", brands: brands)
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
          s in BoatNoodle.BN.Branch,
          where: s.brand_id == ^BN.get_brand_id(conn),
          order_by: s.branchname
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
