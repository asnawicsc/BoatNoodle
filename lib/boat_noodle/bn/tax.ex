defmodule BoatNoodle.BN.Tax do
  use Ecto.Schema
  import Ecto.Changeset


  schema "tax" do
    field :receipt_no, :string
    field :sales_time, :naive_datetime
    field :standard_supply_rate, :decimal
    field :tax, :decimal

    timestamps()
  end

  @doc false
  def changeset(tax, attrs) do
    tax
    |> cast(attrs, [:sales_time, :receipt_no, :tax, :standard_supply_rate])
    |> validate_required([:sales_time, :receipt_no, :tax, :standard_supply_rate])
  end
end
