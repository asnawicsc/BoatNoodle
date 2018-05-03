defmodule BoatNoodle.BN.DiscountType do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "discount_type" do
    field :disctypeid, :integer, primary_key: true
    field :disctypename, :string
  end

  @doc false
  def changeset(discount_type, attrs) do
    discount_type
    |> cast(attrs, [:disctypeid, :disctypename])

  end
end
