defmodule BoatNoodle.BN.DiscountItem do
  use Ecto.Schema
  import Ecto.Changeset


  schema "discount_item" do
    field :description, :string
    field :discount_catalog, :string
    field :discount_category, :string
    field :discount_name, :string
    field :discount_percentage, :string
    field :discount_type, :string
    field :minimum_spend, :integer
    field :status, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(discount_item, attrs) do
    discount_item
    |> cast(attrs, [:discount_name, :description, :discount_type, :discount_category, :discount_percentage, :status, :minimum_spend, :discount_catalog])
    |> validate_required([:discount_name, :description, :discount_type, :discount_category, :discount_percentage, :status, :minimum_spend, :discount_catalog])
  end
end
