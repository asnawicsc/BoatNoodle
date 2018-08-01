defmodule BoatNoodle.Images.Picture do
  use Ecto.Schema
  import Ecto.Changeset

  schema "picture" do
    field(:bin, :binary)
    field(:file_type, :string)
    field(:filename, :string)
    field(:gallery_id, :integer)
    field(:url, :string)
  end

  @doc false
  def changeset(picture, attrs,user_id,action) do
    picture=picture
    |> cast(attrs, [:filename, :file_type, :bin, :url, :gallery_id])

        if action == "new" or action =="edit" do

      
     else

       BoatNoodle.BN.ModalLog.changeset(%BoatNoodle.BN.ModalLog{},%{name: "picture", user_id: user_id,description: Poison.encode!(attrs),action: action})|>BoatNoodle.Repo.insert()
    end

    

    picture
  end
end
