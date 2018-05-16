defmodule BoatNoodle.BN.ItemSubcat do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "item_subcat" do
    field :created_at, :utc_datetime
    field :enable_disc, :integer
    field :include_spend, :integer
    field :is_activate, :integer
    field :is_categorize, :integer
    field :is_combo, :integer
    field :is_default_combo, :integer
    field :is_delete, :integer
    field :is_print, :integer
    field :itemcatid, :string
    field :itemcode, :string
    field :itemdesc, :string
    field :itemimage, :string
    field :itemname, :string
    field :itemprice, :decimal
    field :part_code, :string
    field :price_code, :string
    field :product_code, :string
    field :subcatid, :integer,primary_key: true
    field :updated_at, :utc_datetime


  end

  @doc false
  def changeset(item_subcat, attrs) do
    item_subcat
    |> cast(attrs, [:subcatid, :itemcatid, :itemname, :itemcode, :product_code, :price_code, :part_code, :itemdesc, :itemprice, :itemimage, :is_categorize, :is_activate, :is_combo, :is_default_combo, :is_delete, :enable_disc, :include_spend, :is_print, :updated_at, :created_at])
     end
end
