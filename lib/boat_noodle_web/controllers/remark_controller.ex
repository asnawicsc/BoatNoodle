defmodule BoatNoodleWeb.RemarkController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.Remark
  require(IEx)

  def index(conn, _params) do
    remark = Repo.all(Remark)
    render(conn, "index.html", remark: remark)
  end

  def new(conn, _params) do
    changeset = Remark.changeset(%BoatNoodle.BN.Remark{},%{},BN.current_user(conn),"new")
    item=Repo.all(from s in BoatNoodle.BN.ItemCat, where: s.brand_id==^BN.get_brand_id(conn),
      select: %{itemcatname: s.itemcatname,itemcatid: s.itemcatid})
  
    render(conn, "new.html", changeset: changeset, item: item)
  end

  def create(conn, %{"remark" => remark_params}) do
     remark_params = Map.put(remark_params, "brand_id", BN.get_brand_id(conn))

changeset=BoatNoodle.BN.Remark.changeset(%BoatNoodle.BN.Remark{},remark_params,BN.current_user(conn),"Create")

    case BoatNoodle.Repo.insert(changeset) do
      {:ok, remark} ->
        conn
        |> put_flash(:info, "Remark created successfully.")
        |> redirect(to: menu_item_path(conn, :index, BN.get_domain(conn)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
   remark = Repo.get_by(BoatNoodle.BN.Remark,itemsremarkid: id, brand_id: BN.get_brand_id(conn) )
    render(conn, "show.html", remark: remark)
  end

  def edit(conn, %{"id" => id}) do
    remark = Repo.get_by(BoatNoodle.BN.Remark,itemsremarkid: id, brand_id: BN.get_brand_id(conn) )
   changeset=BoatNoodle.BN.Remark.changeset(remark,%{}, BN.current_user(conn),"edit")
    item = BN.list_itemcat() |> Enum.map(fn x -> {x.itemcatname, x.itemcatid} end)
    render(conn, "edit.html", remark: remark, changeset: changeset, item: item)
  end

  def update(conn, %{"id" => id, "remark" => remark_params}) do
    remark = Repo.get_by(BoatNoodle.BN.Remark,itemsremarkid: id, brand_id: BN.get_brand_id(conn) )
changeset=BoatNoodle.BN.Remark.changeset(remark,remark_params, BN.current_user(conn),"Update")
    case BoatNoodle.Repo.update(changeset) do
      {:ok, remark} ->
        conn
        |> put_flash(:info, "Remark updated successfully.")
        |> redirect(to: menu_item_path(conn, :index, BN.get_domain(conn)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", remark: remark, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
 remark = Repo.get_by(BoatNoodle.BN.Remark,itemsremarkid: id, brand_id: BN.get_brand_id(conn) )
    {:ok, _remark} = BN.delete_remark(remark)

    conn
    |> put_flash(:info, "Remark deleted successfully.")
    |> redirect(to: remark_path(conn, :index, BN.get_domain(conn)))
  end
end
