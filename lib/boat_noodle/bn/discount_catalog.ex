defmodule BoatNoodle.BN.DiscountCatalog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "discount_catalog" do
    field(:id, :integer, primary_key: true)
    field(:name, :string)
    field(:categories, :string)
    field(:discounts, :string)
    field(:brand_id, :integer, primary_key: true)
  end

  @doc false
  def changeset(discount_catalog, attrs) do
    discount_catalog
    |> cast(attrs, [:brand_id, :id, :name, :categories, :discounts])
  end
end
