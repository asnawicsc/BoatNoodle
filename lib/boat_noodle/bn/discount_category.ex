defmodule BoatNoodle.BN.DiscountCategory do
  use Ecto.Schema
  import Ecto.Changeset


  schema "discount_category" do
    field :amount_percentage, :integer
    field :description, :string
    field :discount_catalog, :string
    field :discount_type, :string
    field :name, :string
    field :status, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(discount_category, attrs) do
    discount_category
    |> cast(attrs, [:name, :description, :discount_type, :amount_percentage, :status, :discount_catalog])
    |> validate_required([:name, :description, :discount_type, :amount_percentage, :status, :discount_catalog])
  end
end
