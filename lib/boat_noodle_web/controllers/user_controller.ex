defmodule BoatNoodleWeb.UserController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.User
  alias BoatNoodle.BN.UserRole
  alias BoatNoodle.Images
  alias BoatNoodle.Images.{Gallery, Picture}
  require(IEx)

  def index(conn, _params) do
    user =
      Repo.all(
        from(
          u in User,
          left_join: r in UserRole,
          on: u.roleid == r.roleid,
          where: u.brand_id == ^BN.get_brand_id(conn),
          select: %{
            id: u.id,
            username: u.username,
            email: u.email,
            roleid: r.role_name,
            manager_access: u.manager_access
          },
          order_by: [u.username]
        )
      )

    manager_access_users = user |> Enum.filter(fn x -> x.manager_access == 1 end)
    # branch access
    # list all the users with manager access
    uba = Repo.all(from(u in UserBranchAccess)) |> Enum.group_by(fn x -> x.userid end)

    # list each users branch ids
    # find all branches
    branches =
      Repo.all(
        from(b in Branch, select: %{name: b.branchname, id: b.branchid}, order_by: [b.branchname])
      )

    staff =
      Repo.all(
        from(
          s in Staff,
          left_join: r in BoatNoodle.BN.StaffType,
          on: s.staff_type_id == r.id,
          select: %{
            id: s.staff_id,
            staff_name: s.staff_name,
            staff_contact: s.staff_contact,
            staff_email: s.staff_email,
            staff_type_id: r.name
          }
        )
      )

    render(
      conn,
      "index.html",
      user: user,
      branches: branches,
      manager_access_users: manager_access_users,
      uba: uba,
      staff: staff
    )
  end

  def new(conn, _params) do
    changeset = User.changeset(%BoatNoodle.BN.User{}, %{}, BN.current_user(conn), "new")
    roles = BN.list_user_role() |> Enum.map(fn x -> {x.role_name, x.roleid} end)
    render(conn, "new.html", changeset: changeset, roles: roles)
  end

  def create(conn, %{"user" => user_params}) do
    crypted_password = Comeonin.Bcrypt.hashpwsalt(user_params["password"])
    user_params = Map.put(user_params, "password", crypted_password)

    changeset =
      BoatNoodle.BN.User.changeset(
        %BoatNoodle.BN.User{},
        user_params,
        BN.current_user(conn),
        "Create"
      )

    case BoatNoodle.Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :index, BN.get_domain(conn)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = BN.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit_user(conn, params) do
    render(conn, "edit_user.html")
  end

  def edit(conn, %{"id" => id}) do
    user = BN.get_user!(id)
    changeset = BoatNoodle.BN.User.changeset(user, %{}, BN.current_user(conn), "edit")

    if user.gall_id == 1 do
      path = File.cwd!() <> "/media/demo.png"
      {:ok, bin} = File.read(path)
      bin = Base.encode64(bin)
      picture = %{bin: bin}

      render(
        conn,
        "edit.html",
        user: user,
        changeset: changeset,
        picture: picture
      )
    else
      gallery = Repo.get(Gallery, user.gall_id)
      picture = Repo.get_by(Picture, file_type: "profile_picture", gallery_id: gallery.id)

      render(
        conn,
        "edit.html",
        user: user,
        changeset: changeset,
        gallery: gallery,
        picture: picture
      )
    end
  end

  def update_profile(conn, params) do
    user = BN.get_user!(params["user_id"])

    if params["new_pass"] != "" or params["old_pass"] != "" do
      if params["new_pass"] == params["old_pass"] do
        user_params = %{
          username: params["username"],
          email: params["email"]
        }

        crypted_password = Comeonin.Bcrypt.hashpwsalt(conn.params["new_pass"])
        p2 = String.replace(crypted_password, "$2b", "$2y")
        user_params = Map.put(user_params, :password, p2)

        changeset =
          BoatNoodle.BN.User.changeset(user, user_params, BN.current_user(conn), "Update")

        case BoatNoodle.Repo.update(changeset) do
          {:ok, user} ->
            conn
            |> put_flash(:info, "User updated successfully.")
            |> redirect(to: user_path(conn, :edit, BN.get_domain(conn), params["user_id"]))

          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_flash(:error, "User update unsuccessful.")
            |> redirect(to: user_path(conn, :edit, BN.get_domain(conn), params["user_id"]))
        end
      else
        conn
        |> put_flash(:error, "New Password and Confirmation Password do not match")
        |> redirect(to: user_path(conn, :edit, BN.get_domain(conn), params["user_id"]))
      end
    else
      user_params = %{
        username: params["username"],
        email: params["email"]
      }

      changeset = BoatNoodle.BN.User.changeset(user, user_params, BN.current_user(conn), "Update")

      case BoatNoodle.Repo.update(changeset) do
        {:ok, user} ->
          conn
          |> put_flash(:info, "User updated successfully.")
          |> redirect(to: user_path(conn, :edit, BN.get_domain(conn), params["user_id"]))

        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> put_flash(:error, "User update unsuccessful.")
          |> redirect(to: user_path(conn, :edit, BN.get_domain(conn), params["user_id"]))
      end
    end
  end

  def update_profile_picture(conn, params) do
    brand = Repo.get_by(Brand, domain_name: params["brand"])
    user = Repo.get_by(User, id: params["user_id"], brand_id: brand.id)

    if params["user"]["image"] == nil do
      conn
      |> put_flash(:error, "No image found!")
      |> redirect(to: user_path(conn, :edit, BN.get_domain(conn), params["user_id"]))
    else
      if user.gall_id == 1 do
        {:ok, gallery} = Images.create_gallery(%{})
        {:ok, user} = BN.update_user(user, %{gall_id: gallery.id})

        case Images.upload(params["user"]["image"], user.id, gallery.id, "profile_picture") do
          {:ok, picture} ->
            nil
        end

        conn
        |> put_flash(:info, "Profile picture updated successfully.")
        |> redirect(to: user_path(conn, :edit, params["user_id"]))
      else
        gallery = Repo.get(Gallery, user.gall_id)

        old_pic = Repo.get_by(Picture, gallery_id: gallery.id, file_type: "profile_picture")

        if old_pic != nil do
          Images.delete_picture(old_pic)
        end

        case Images.upload(params["user"]["image"], user.id, gallery.id, "profile_picture") do
          {:ok, picture} ->
            nil
        end

        conn
        |> put_flash(:info, "Profile picture updated successfully.")
        |> redirect(to: user_path(conn, :edit, BN.get_domain(conn), params["user_id"]))
      end
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = BN.get_user!(id)

    case BN.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, BN.get_domain(conn), user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = BN.get_user!(id)
    {:ok, _user} = BN.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index, BN.get_domain(conn)))
  end

  def login(conn, params) do
    render(conn, "login.html", layout: {BoatNoodleWeb.LayoutView, "full_bg.html"})
  end

  def login_management(conn, params) do
    render(conn, "management_login.html", layout: {BoatNoodleWeb.LayoutView, "full_bg.html"})
  end

  def authenticate_login(conn, %{"username" => username, "password" => password}) do
    brand = Repo.get_by(Brand, domain_name: conn.params["brand"])
    user = Repo.get_by(User, username: username)

    if user != nil do
      roleid = user.roleid

      if roleid == 7 do
        p2 = String.replace(user.password, "$2y", "$2b")

        if Comeonin.Bcrypt.checkpw(password, p2) do
          conn
          |> put_session(:user_id, user.id)
          |> put_session(:brand, conn.params["brand"])
          |> put_session(:brand_id, BN.brand_id(conn))
          |> redirect(to: page_path(conn, :index2, conn.params["brand"]))
        else
          conn
          |> put_flash(:error, "Wrong password!")
          |> redirect(to: user_path(conn, :login, conn.params["brand"]))
        end
      else
        user2 = Repo.get_by(User, username: username, brand_id: brand.id)

        if user2 != nil do
          p2 = String.replace(user2.password, "$2y", "$2b")

          if Comeonin.Bcrypt.checkpw(password, p2) do
            conn
            |> put_session(:user_id, user2.id)
            |> put_session(:brand, conn.params["brand"])
            |> put_session(:brand_id, BN.brand_id(conn))
            |> redirect(to: page_path(conn, :index2, conn.params["brand"]))
          else
            conn
            |> put_flash(:error, "Wrong password!")
            |> redirect(to: user_path(conn, :login, conn.params["brand"]))
          end
        else
          conn
          |> put_flash(:error, "User not found")
          |> redirect(to: user_path(conn, :login, conn.params["brand"]))
        end
      end
    else
      conn
      |> put_flash(:error, "User not found")
      |> redirect(to: user_path(conn, :login, conn.params["brand"]))
    end
  end

  def forget_password(conn, params) do
    render(conn, "forget_password.html", layout: {BoatNoodleWeb.LayoutView, "full_bg.html"})
  end

  def forget_password_email(conn, params) do
    user = Repo.get_by(User, email: params["email"])

    if user == nil do
      conn
      |> put_flash(:error, "User not found")
      |> redirect(to: user_path(conn, :forget_password, BN.get_domain(conn)))
    else
      # if user.password != "" do
      #   password_not_set = false
      #   decrypted_pasword = "123"

      #   BoatNoodle.Email.forget_password(
      #     user.email,
      #     decrypted_pasword,
      #     user.username,
      #     password_not_set
      #   )
      #   |> BoatNoodle.Mailer.deliver_later()
      # else
      preset_password = "8888"
      crypted_password = Comeonin.Bcrypt.hashpwsalt(preset_password)
      p2 = String.replace(crypted_password, "$2b", "$2y")
      user_params = %{password: p2}

      changeset = BoatNoodle.BN.User.changeset(user, user_params, BN.current_user(conn), "Update")

      BoatNoodle.Repo.update(changeset)
      password_not_set = true

      BoatNoodle.Email.forget_password(
        user.email,
        preset_password,
        user.username,
        password_not_set
      )
      |> BoatNoodle.Mailer.deliver_later()

      # end

      conn
      |> put_flash(:info, "Password has been sent to your email. Please check !")
      |> redirect(to: page_path(conn, :report_login))
    end
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> delete_session(:brand_id)
    |> delete_session(:brand)
    |> put_flash(:info, "Logout successfully")
    |> redirect(to: page_path(conn, :report_login))
  end
end
