defmodule BoatNoodle.BN.DiscountCatalogMaster do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "discount" do
    field :discountid, :integer, primary_key: true
    field :discname, :string
    field :descriptions, :string
    field :discamtpercentage, :decimal
    field :target_cat, :integer
    field :is_used, :integer
    field :disc_qty, :integer
    field :target_itemcode, :string
    field :disctype, :string
    field :is_categorize, :integer
    field :is_visable, :integer
    field :is_delete, :integer

  end

  @doc false
  def changeset(discount_catalog_master, attrs) do
    discount_catalog_master
    |> cast(attrs, [:discountid,:is_visable,:is_categorize,:disctype,:target_itemcode,:disc_qty,:is_used,:target_cat,:discamtpercentage,:descriptions,:discname,:catalog_name])

  end
end
