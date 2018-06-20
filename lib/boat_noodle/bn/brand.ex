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
  def changeset(brand, attrs) do
    brand
    |> cast(attrs, [:name, :domain_name, :bin, :file_name])
  end
end
