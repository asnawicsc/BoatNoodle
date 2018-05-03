defmodule BoatNoodle.BN.DiscountItem do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "discountitems" do
    field :discountitemsid, :integer, primary_key: true
    field :discountid, :integer
    field :discitemsname, :string
    field :descriptions, :string
    field :discamtpercentage, :decimal
    field :target_cat, :integer
    field :is_used, :integer
    field :disc_qty, :integer
    field :disctype, :string
    field :is_categorize, :integer
    field :is_targetmenuitems, :integer
    field :is_visable, :integer
    field :is_delete, :integer
    field :min_spend, :decimal

  end

  @doc false
  def changeset(discount_item, attrs) do
    discount_item
    |> cast(attrs, [:min_spend,:is_delete,:is_visable,:is_targetmenuitems,:is_categorize,:disctype,:disc_qty,:is_used,:target_cat,:discamtpercentage,:descriptions,:discitemsname,:discountid,:discountitemsid])
  end
end
