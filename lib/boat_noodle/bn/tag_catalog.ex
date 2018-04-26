defmodule BoatNoodle.BN.TagCatalog do
  use Ecto.Schema
  import Ecto.Changeset


  schema "tag_catalog" do
    field :description, :string
    field :name, :string
    field :tag_category, :string
    field :tag_items, :string

    timestamps()
  end

  @doc false
  def changeset(tag_catalog, attrs) do
    tag_catalog
    |> cast(attrs, [:name, :description, :tag_category, :tag_items])
    |> validate_required([:name, :description, :tag_category, :tag_items])
  end
end
