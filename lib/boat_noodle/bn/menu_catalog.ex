defmodule BoatNoodle.BN.MenuCatalog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "menu_catalog" do
    field(:id, :integer, primary_key: true)
    field(:name, :string)
    field(:categories, :string, default: "")
    field(:items, :string, default: "")
    field(:combo_items, :string, default: "")
    field(:brand_id, :integer, primary_key: true)
  end

  @doc false
  def changeset(menu_catalog, attrs) do
    menu_catalog
    |> cast(attrs, [:brand_id, :id, :name, :categories, :items, :combo_items])
  end
end
