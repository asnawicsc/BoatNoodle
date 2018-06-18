defmodule BoatNoodle.BN.Brand do
  use Ecto.Schema
  import Ecto.Changeset

  schema "brand" do
    field(:name, :string)
    field(:domain_name, :string)
  end

  @doc false
  def changeset(brand, attrs) do
    brand
    |> cast(attrs, [:name, :domain_name])
  end
end
