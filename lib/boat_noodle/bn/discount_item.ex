defmodule BoatNoodle.BN.DiscountItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "discountitems" do
    field(:discountitemsid, :integer, primary_key: true)
    field(:discountid, :integer)
    field(:discitemsname, :string)
    field(:descriptions, :string)
    field(:discamtpercentage, :decimal, default: 0)
    field(:target_cat, :integer, default: 0)
    field(:is_used, :integer, default: 0)
    field(:disc_qty, :integer, default: 0)
    field(:disctype, :string)
    field(:is_categorize, :integer, default: 0)
    field(:is_targetmenuitems, :integer, default: 0)
    field(:is_visable, :integer, default: 0)
    field(:is_delete, :integer, default: 0)
    field(:min_spend, :decimal)
    field(:multi_item_list, :string, default: "")
    field(:pre_req_item, :string, default: "")
    field(:min_order, :integer)
    field(:is_force_apply, :boolean, default: false)
    field(:is_oc, :integer, default: 0)
    field(:brand_id, :integer, primary_key: true)
  end

  @doc false
  def changeset(discount_item, attrs, user_id, action) do
    discount_item =
      discount_item
      |> cast(attrs, [
        :is_oc,
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

    if action == "new" or action == "edit" do
    else
      if action == "Update" do
        attrs = Map.put(attrs, "discountitemsid", discount_item.data.discountitemsid)
      end

      BoatNoodle.BN.ModalLog.changeset(%BoatNoodle.BN.ModalLog{}, %{
        name: "discount_item",
        user_id: user_id,
        description: Poison.encode!(attrs),
        action: action
      })
      |> BoatNoodle.Repo.insert()
    end

    discount_item
  end
end
