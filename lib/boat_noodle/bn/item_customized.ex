defmodule BoatNoodle.BN.ItemCustomized do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "item_customized" do
    field :availability, :string
    field :created_at, :utc_datetime
    field :customize_code, :string
    field :customize_detail, :string
    field :itemcustomid,:integer, primary_key: true
    field :price, :decimal
    field :subcatid, :string
    field :updated_at, :utc_datetime

  end

  @doc false
  def changeset(item_customized, attrs) do
    item_customized
    |> cast(attrs, [:itemcustomid, :subcatid, :customize_code, :customize_detail, :price, :availability, :created_at, :updated_at])
   end
end
