defmodule BoatNoodle.BN.MenuItem do
  use Ecto.Schema
  import Ecto.Changeset


  schema "menu_item" do
    field :active, :boolean, default: false
    field :category, :string
    field :enable_discount, :boolean, default: false
    field :is_included_in_minimum_spend, :boolean, default: false
    field :item, :string
    field :item_code, :string
    field :item_description, :string
    field :item_image, :string
    field :item_name, :string
    field :menu_catalogs, :string
    field :part_code, :string
    field :price, :decimal
    field :price_code, :string
    field :tags, :string

    timestamps()
  end

  @doc false
  def changeset(menu_item, attrs) do
    menu_item
    |> cast(attrs, [:item_code, :item, :item_name, :item_description, :price, :item_image, :category, :part_code, :price_code, :active, :enable_discount, :is_included_in_minimum_spend, :tags, :menu_catalogs])
    |> validate_required([:item_code, :item, :item_name, :item_description, :price, :item_image, :category, :part_code, :price_code, :active, :enable_discount, :is_included_in_minimum_spend, :tags, :menu_catalogs])
  end
end
