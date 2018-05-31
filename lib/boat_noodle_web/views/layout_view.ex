defmodule BoatNoodleWeb.LayoutView do
  use BoatNoodleWeb, :view
  alias BoatNoodle.BN
  alias BoatNoodle.BN.User
  alias BoatNoodle.Images
  alias BoatNoodle.Images.{Gallery, Picture}
  import Ecto.Query
  require IEx

  def user(conn) do
    user = Repo.get(User, conn.private.plug_session["user_id"])

    if user.gall_id != nil do
      gallery = Repo.get(Gallery, user.gall_id)
      picture = Repo.get_by(Picture, file_type: "profile_picture", gallery_id: gallery.id)
      %{name: user.username, bin: picture.bin}
    else
      %{name: user.username, bin: ""}
    end
  end
end
