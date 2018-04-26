defmodule BoatNoodle.BN.TagItems do
  use Ecto.Schema
  import Ecto.Changeset


  schema "tag_items" do
    field :item_name, :string
    field :printer, :string
    field :tag_name, :string

    timestamps()
  end

  @doc false
  def changeset(tag_items, attrs) do
    tag_items
    |> cast(attrs, [:item_name, :tag_name, :printer])
    |> validate_required([:item_name, :tag_name, :printer])
  end
end
