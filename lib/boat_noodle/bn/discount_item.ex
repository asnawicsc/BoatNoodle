defmodule BoatNoodle.BN.DiscountItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "discountitems" do
    field(:discountitemsid, :integer, primary_key: true)
    field(:discountid, :integer)
    field(:discitemsname, :string)
    field(:descriptions, :string)
    field(:discamtpercentage, :decimal)
    field(:target_cat, :integer, default: 0)
    field(:is_used, :integer, default: 0)
    field(:disc_qty, :integer, default: 0)
    field(:disctype, :string)
    field(:is_categorize, :integer, default: 0)
    field(:is_targetmenuitems, :integer, default: 0)
    field(:is_visable, :integer, default: 0)
    field(:is_delete, :integer, default: 0)
    field(:min_spend, :decimal)
    field(:multi_item_list, :string)
    field(:pre_req_item, :string)
    field(:min_order, :integer)
    field(:is_force_apply, :boolean, default: false)

    field(:brand_id, :integer, primary_key: true)
  end

  @doc false
  def changeset(discount_item, attrs) do
    discount_item
    |> cast(attrs, [
      :is_force_apply,
      :min_order,
      :brand_id,
      :min_spend,
      :multi_item_list,
      :is_delete,
      :is_visable,
      :is_targetmenuitems,
      :is_categorize,
      :disctype,
      :disc_qty,
      :is_used,
      :target_cat,
      :discamtpercentage,
      :descriptions,
      :discitemsname,
      :discountid,
      :discountitemsid,
      :pre_req_item
    ])
  end
end
