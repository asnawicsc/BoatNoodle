defmodule BoatNoodle.BN.MenuCatalogMaster do
  use Ecto.Schema
  import Ecto.Changeset


  schema "menu_catalog_master" do
    field :catalog_name, :string

    timestamps()
  end

  @doc false
  def changeset(menu_catalog_master, attrs) do
    menu_catalog_master
    |> cast(attrs, [:catalog_name])
    |> validate_required([:catalog_name])
  end
end
