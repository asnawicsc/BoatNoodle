defmodule BoatNoodle.BN.DiscountCatalog do
  use Ecto.Schema
  import Ecto.Changeset


  schema "discount_catalog" do
    field :discount_catalog_master_id, :integer
    field :discount_categories, :string
    field :discount_category, :string
    field :discount_name, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(discount_catalog, attrs) do
    discount_catalog
    |> cast(attrs, [:discount_catalog_master_id, :name, :discount_categories, :discount_category, :discount_name])
    |> validate_required([:discount_catalog_master_id, :name, :discount_categories, :discount_category, :discount_name])
  end
end
