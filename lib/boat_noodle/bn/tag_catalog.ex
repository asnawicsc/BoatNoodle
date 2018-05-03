defmodule BoatNoodle.BN.TagCatalog do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "tag_catalog" do
    field :id, :integer, primary_key: true
    field :description, :string
    field :name, :string
    field :tags, :string
    field :tagitems, :string

 
  end

  @doc false
  def changeset(tag_catalog, attrs) do
    tag_catalog
    |> cast(attrs, [:id,:name, :description, :tags, :tagitems])
  
  end
end
