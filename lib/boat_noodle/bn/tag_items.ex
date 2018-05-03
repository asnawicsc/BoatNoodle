defmodule BoatNoodle.BN.TagItems do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "tag_item" do
    field :tagitemid, :integer, primary_key: true
    field :tagid, :string
    field :itemcustomid, :string
    field :is_new, :integer
    field :updated_at, :utc_datetime
    field :created_at, :utc_datetime


  end

  @doc false
  def changeset(tag_item, attrs) do
    tag_item
    |> cast(attrs, [:created_at,:updated_at,:tagitemid,:tagid,:itemcustomid, :is_new])
  end
end
