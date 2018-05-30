defmodule BoatNoodleWeb.UserController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.User
  alias BoatNoodle.Images
  alias BoatNoodle.Images.{Gallery, Picture}
  require(IEx)

  def index(conn, _params) do
    user = Repo.all(User)
    render(conn, "index.html", user: user)
  end

  def new(conn, _params) do
    changeset = BN.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case BN.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :show, user))

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
    changeset = BN.change_user(user)
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

  def update_profile(conn, params) do
    user = BN.get_user!(params["user_id"])

    if params["new_pass"] != "" or params["old_pass"] != "" do
      if params["new_pass"] == params["old_pass"] do
        user_params = %{
          username: params["username"],
          email: params["email"]
        }

        bin = Plug.Crypto.KeyGenerator.generate("resertech", "damien")
        crypted_password = Plug.Crypto.MessageEncryptor.encrypt(params["new_pass"], bin, bin)
        user_params = Map.put(user_params, :password_v2, crypted_password)

        case BN.update_user(user, user_params) do
          {:ok, user} ->
            conn
            |> put_flash(:info, "User updated successfully.")
            |> redirect(to: user_path(conn, :edit, params["user_id"]))

          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_flash(:error, "User update unsuccessful.")
            |> redirect(to: user_path(conn, :edit, params["user_id"]))
        end
      else
        conn
        |> put_flash(:error, "New Password and Confirmation Password do not match")
        |> redirect(to: user_path(conn, :edit, params["user_id"]))
      end
    else
      user_params = %{
        username: params["username"],
        email: params["email"],
        password_v2: user.password_v2
      }

      case BN.update_user(user, user_params) do
        {:ok, user} ->
          conn
          |> put_flash(:info, "User updated successfully.")
          |> redirect(to: user_path(conn, :edit, params["user_id"]))

        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> put_flash(:error, "User update unsuccessful.")
          |> redirect(to: user_path(conn, :edit, params["user_id"]))
      end
    end
  end

  def update_profile_picture(conn, params) do
    user = Repo.get(User, params["user_id"])

    if params["user"]["image"] == nil do
      conn
      |> put_flash(:error, "No image found!")
      |> redirect(to: user_path(conn, :edit, params["user_id"]))
    else
      if user.gall_id == nil do
        {:ok, gallery} = Images.create_gallery(%{})
        {:ok, user} = BN.update_user(user, %{gall_id: gallery.id})

        case Images.upload(params["user"]["image"]) do
          {:ok, picture} ->
            Images.update_picture(picture, %{
              gallery_id: gallery.id,
              file_type: "profile_picture"
            })
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

        case Images.upload(params["user"]["image"]) do
          {:ok, picture} ->
            Images.update_picture(picture, %{
              gallery_id: gallery.id,
              file_type: "profile_picture"
            })
        end

        conn
        |> put_flash(:info, "Profile picture updated successfully.")
        |> redirect(to: user_path(conn, :edit, params["user_id"]))
      end
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = BN.get_user!(id)

    case BN.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = BN.get_user!(id)
    {:ok, _user} = BN.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end

  def login(conn, params) do
    render(conn, "login.html", layout: {BoatNoodleWeb.LayoutView, "full_bg.html"})
  end

  def authenticate_login(conn, %{"username" => username, "password_v2" => password_v2}) do
    user = Repo.get_by(User, username: username)

    if user != nil do
      bin = Plug.Crypto.KeyGenerator.generate("resertech", "damien")
      {:ok, saved_password} = Plug.Crypto.MessageEncryptor.decrypt(user.password_v2, bin, bin)

      if password_v2 == saved_password do
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Login successfully")
        |> redirect(to: page_path(conn, :index))
      else
        conn
        |> put_flash(:error, "Wrong password!")
        |> redirect(to: user_path(conn, :login))
      end
    else
      conn
      |> put_flash(:error, "User not found")
      |> redirect(to: user_path(conn, :login))
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
      |> redirect(to: user_path(conn, :forget_password))
    else
      if user.password_v2 != "" do
        bin = Plug.Crypto.KeyGenerator.generate("resertech", "damien")

        {:ok, decrypted_pasword} =
          Plug.Crypto.MessageEncryptor.decrypt(user.password_v2, bin, bin)

        password_not_set = false

        BoatNoodle.Email.forget_password(
          user.email,
          decrypted_pasword,
          user.username,
          password_not_set
        )
        |> BoatNoodle.Mailer.deliver_later()
      else
        preset_password = "8888"
        bin = Plug.Crypto.KeyGenerator.generate("resertech", "damien")
        crypted_password = Plug.Crypto.MessageEncryptor.encrypt(preset_password, bin, bin)
        user_params = %{password_v2: crypted_password}
        BN.update_user(user, user_params)
        password_not_set = true

        BoatNoodle.Email.forget_password(
          user.email,
          preset_password,
          user.username,
          password_not_set
        )
        |> BoatNoodle.Mailer.deliver_later()
      end

      conn
      |> put_flash(:info, "Password has been sent to your email. Please check !")
      |> redirect(to: user_path(conn, :login))
    end
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> put_flash(:info, "Logout successfully")
    |> redirect(to: user_path(conn, :login))
  end
end
