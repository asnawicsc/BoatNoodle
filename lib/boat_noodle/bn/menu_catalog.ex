defmodule BoatNoodle.BN.MenuCatalog do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "menu_catalog" do
    field :id, :integer, primary_key: true
    field :name, :string
    field :categories, :string
    field :items, :string
    field :combo_items, :string

  end

  @doc false
  def changeset(menu_catalog, attrs) do
    menu_catalog
    |> cast(attrs, [:id, :item_code, :name, :categories, :items, :combo_items])
  
  end
end
