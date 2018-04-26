defmodule BoatNoodle.BN.DiscountCatalogMaster do
  use Ecto.Schema
  import Ecto.Changeset


  schema "discount_catalog_master" do
    field :catalog_name, :string

    timestamps()
  end

  @doc false
  def changeset(discount_catalog_master, attrs) do
    discount_catalog_master
    |> cast(attrs, [:catalog_name])
    |> validate_required([:catalog_name])
  end
end
