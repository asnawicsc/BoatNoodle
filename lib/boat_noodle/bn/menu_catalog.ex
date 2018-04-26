defmodule BoatNoodle.BN.MenuCatalog do
  use Ecto.Schema
  import Ecto.Changeset


  schema "menu_catalog" do
    field :active, :boolean, default: false
    field :category_item, :string
    field :item_code, :string
    field :item_name, :string
    field :menu_catalog_master_id, :integer
    field :price, :decimal
    field :price_code, :string

    timestamps()
  end

  @doc false
  def changeset(menu_catalog, attrs) do
    menu_catalog
    |> cast(attrs, [:menu_catalog_master_id, :item_code, :item_name, :price_code, :price, :active, :category_item])
    |> validate_required([:menu_catalog_master_id, :item_code, :item_name, :price_code, :price, :active, :category_item])
  end
end
