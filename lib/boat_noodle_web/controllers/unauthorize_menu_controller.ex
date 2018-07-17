defmodule BoatNoodleWeb.UnauthorizeMenuController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.UnauthorizeMenu
  require IEx

  def index(conn, _params) do
    unauthorize_menu = BN.list_unauthorize_menu()
    render(conn, "index.html", unauthorize_menu: unauthorize_menu)
  end

  def new(conn, _params) do
    changeset = BN.change_unauthorize_menu(%UnauthorizeMenu{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"unauthorize_menu" => unauthorize_menu_params}) do
    case BN.create_unauthorize_menu(unauthorize_menu_params) do
      {:ok, unauthorize_menu} ->
        conn
        |> put_flash(:info, "Unauthorize menu created successfully.")
        |> redirect(to: unauthorize_menu_path(conn, :show, BN.get_domain(@conn), unauthorize_menu))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    unauthorize_menu = BN.get_unauthorize_menu!(id)
    render(conn, "show.html", unauthorize_menu: unauthorize_menu, brand_id: BN.get_brand_id(conn))
  end

  def edit(conn, %{"id" => id}) do
    unauthorize_menu = BN.get_unauthorize_menu!(id)
    changeset = BN.change_unauthorize_menu(unauthorize_menu)
    render(conn, "edit.html", unauthorize_menu: unauthorize_menu, changeset: changeset)
  end

  def update(conn, %{"id" => id, "unauthorize_menu" => unauthorize_menu_params}) do
    unauthorize_menu = BN.get_unauthorize_menu!(id)

    case BN.update_unauthorize_menu(unauthorize_menu, unauthorize_menu_params) do
      {:ok, unauthorize_menu} ->
        conn
        |> put_flash(:info, "Unauthorize menu updated successfully.")
        |> redirect(to: unauthorize_menu_path(conn, :show, unauthorize_menu))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", unauthorize_menu: unauthorize_menu, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    unauthorize_menu = BN.get_unauthorize_menu!(id)
    {:ok, _unauthorize_menu} = BN.delete_unauthorize_menu(unauthorize_menu)

    conn
    |> put_flash(:info, "Unauthorize menu deleted successfully.")
    |> redirect(to: unauthorize_menu_path(conn, :index, BN.get_domain(conn)))
  end

  def menu(conn, params) do

     menu_admin = BoatNoodle.Repo.all(from b in BoatNoodle.BN.UnauthorizeMenu,
    where: b.role_id==1 and b.brand_id==^BN.get_brand_id(conn),
     select: %{desc: b.desc,id: b.id,
     active: b.active},order_by: b.desc)

     menu_manager = BoatNoodle.Repo.all(from b in BoatNoodle.BN.UnauthorizeMenu,
     where:  b.role_id==2 and b.brand_id==^BN.get_brand_id(conn),
     select: %{desc: b.desc,id: b.id,
     active: b.active},order_by: b.desc)

     menu_cashier = BoatNoodle.Repo.all(from b in BoatNoodle.BN.UnauthorizeMenu,
     where:  b.role_id==3 and b.brand_id==^BN.get_brand_id(conn),
     select: %{desc: b.desc,id: b.id,
     active: b.active},order_by: b.desc)

     menu_staff = BoatNoodle.Repo.all(from b in BoatNoodle.BN.UnauthorizeMenu,
     where: b.role_id==4 and b.brand_id==^BN.get_brand_id(conn),
     select: %{desc: b.desc,id: b.id,
     active: b.active},order_by: b.desc)


     menu_guest = BoatNoodle.Repo.all(from b in BoatNoodle.BN.UnauthorizeMenu,
     where:  b.role_id==5 and b.brand_id==^BN.get_brand_id(conn),
     select: %{desc: b.desc,id: b.id,
     active: b.active},order_by: b.desc)

     menu_supervisor = BoatNoodle.Repo.all(from b in BoatNoodle.BN.UnauthorizeMenu,
     where: b.role_id==6 and b.brand_id==^BN.get_brand_id(conn),
     select: %{desc: b.desc,id: b.id,
     active: b.active},order_by: b.desc)


    render(conn, "menu.html",menu_supervisor: menu_supervisor,menu_guest: menu_guest,menu_staff: menu_staff,menu_cashier: menu_cashier,menu_manager: menu_manager, menu_admin: menu_admin)
  end

  def update_menu(conn, params) do

    params["admin"]
    params["manager"]
    params["cashier"]
    params["staff"]
    params["guest"]
    params["supervisor"]

    all_menu=Repo.all(from s in UnauthorizeMenu)

    for menu <- all_menu do

      menu=Repo.get_by(UnauthorizeMenu,id: menu.id, brand_id: BoatNoodle.BN.get_brand_id(conn))

      BN.update_unauthorize_menu(menu, %{active: 0})
      
    end

  if params["admin"] != nil do
    for item <-  params["admin"] do
      id=item|>elem(0)|>String.to_integer

      menu=Repo.get_by(UnauthorizeMenu,id: id, brand_id: BoatNoodle.BN.get_brand_id(conn))
    
      BN.update_unauthorize_menu(menu, %{active: 1})
    end
  end
  if params["manager"] != nil do
    for item <-  params["manager"] do
       id=item|>elem(0)|>String.to_integer
       menu=Repo.get_by(UnauthorizeMenu,id: id, brand_id: BoatNoodle.BN.get_brand_id(conn))


      BN.update_unauthorize_menu(menu, %{active: 1})
    end
  end
  if params["cashier"] != nil do
    for item <-  params["cashier"] do
       id=item|>elem(0)|>String.to_integer
       menu=Repo.get_by(UnauthorizeMenu,id: id, brand_id: BoatNoodle.BN.get_brand_id(conn))
      BN.update_unauthorize_menu(menu, %{active: 1})
    end
  end
  if params["staff"] != nil do
    for item <-  params["staff"] do
      id=item|>elem(0)|>String.to_integer
      menu=Repo.get_by(UnauthorizeMenu,id: id, brand_id: BoatNoodle.BN.get_brand_id(conn))
     BN.update_unauthorize_menu(menu, %{active: 1})
    end
  end
  if params["guest"] != nil do
    for item <-  params["guest"] do
       id=item|>elem(0)|>String.to_integer
       menu=Repo.get_by(UnauthorizeMenu,id: id, brand_id: BoatNoodle.BN.get_brand_id(conn))
      BN.update_unauthorize_menu(menu, %{active: 1})
    end
  end
  if params["supervisor"] != nil do
    for item <-  params["supervisor"] do
       id=item|>elem(0)|>String.to_integer
       menu=Repo.get_by(UnauthorizeMenu,id: id, brand_id: BoatNoodle.BN.get_brand_id(conn))
      BN.update_unauthorize_menu(menu, %{active: 1})
    end
  end

      conn
        |> put_flash(:info, "Unauthorize menu updated successfully.")
        |> redirect(to: unauthorize_menu_path(conn, :menu, BN.get_domain(conn)))
  end

 
end
