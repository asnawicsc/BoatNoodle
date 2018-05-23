defmodule BoatNoodle.BN.Discount do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "discount" do
    field :descriptions, :string
    field :disc_qty, :integer
    field :discamtpercentage, :decimal
    field :discname, :string
    field :discountid, :integer, primary_key: true
    field :disctype, :string
    field :is_categorize, :integer
    field :is_delete, :integer
    field :is_used, :integer
    field :is_visable, :integer
    field :target_itemcode, :string
    field :target_cat, :integer

  end

  @doc false
  def changeset(discount, attrs) do
    discount
    |> cast(attrs, [:discount_id, :discname, :descriptions, :discamtpercentage, :target_cat, :is_used, :disc_qty, :targer_itemcode, :disctype, :is_categorize, :is_visible, :is_delete])
  end
end
