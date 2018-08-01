defmodule BoatNoodle.BN.Brand do
  use Ecto.Schema
  import Ecto.Changeset

  schema "brand" do
    field(:bin, :binary)
    field(:domain_name, :string)
    field(:name, :string)
    field(:file_name, :string)
  end

  @doc false
  def changeset(brand, attrs,user_id,action) do
    brand=brand
    |> cast(attrs, [:name, :domain_name, :bin, :file_name])


    if action == "new" or action =="edit" do

      
     else

       BoatNoodle.BN.ModalLog.changeset(%BoatNoodle.BN.ModalLog{},%{name: "itemsremak", user_id: user_id,description: Poison.encode!(attrs),action: action})|>BoatNoodle.Repo.insert()
    end

    brand
  end
end
