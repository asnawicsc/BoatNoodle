defmodule BoatNoodle.BN.ItemSubcat do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "item_subcat" do
    field(:subcatid, :integer, primary_key: true)
    field(:created_at, :utc_datetime)
    field(:enable_disc, :integer, default: 1)
    field(:include_spend, :integer, default: 1)
    field(:is_activate, :integer, default: 1)
    field(:is_categorize, :integer, default: 0)
    field(:is_comboitem, :integer, default: 0)
    field(:is_default_combo, :integer, default: 0)
    field(:is_delete, :integer, default: 0)
    field(:is_print, :integer, default: 1)
    field(:itemcatid, :string)
    field(:itemcode, :string)
    field(:itemdesc, :string)
    field(:itemimage, :string)
    field(:itemname, :string)
    field(:itemprice, :decimal, default: 0)
    field(:part_code, :string)
    field(:price_code, :string)
    field(:product_code, :string)
    field(:updated_at, :utc_datetime)
    field(:brand_id, :integer, primary_key: true)
  end

  @doc false
  def changeset(item_subcat, attrs) do
    item_subcat
    |> cast(attrs, [
      :brand_id,
      :subcatid,
      :itemcatid,
      :itemname,
      :itemcode,
      :product_code,
      :price_code,
      :part_code,
      :itemdesc,
      :itemprice,
      :itemimage,
      :is_categorize,
      :is_activate,
      :is_comboitem,
      :is_default_combo,
      :is_delete,
      :enable_disc,
      :include_spend,
      :is_print,
      :updated_at,
      :created_at
    ])
    |> unique_constraint(:subcatid, name: "PRIMARY")
  end
end
