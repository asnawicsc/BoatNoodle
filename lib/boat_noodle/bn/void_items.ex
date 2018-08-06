defmodule BoatNoodle.BN.VoidItems do
  use Ecto.Schema
  import Ecto.Changeset

  schema "voiditems" do
    field(:discount, :float)
    field(:discountitemsid, :integer)
    field(:displayprice, :string)
    field(:is_print, :integer)
    field(:is_void, :integer)
    field(:itemcode, :string)
    field(:itemid, :integer)
    field(:itemname, :string)
    field(:itempriceperqty, :decimal)
    field(:orderid, :string)
    field(:price, :decimal)
    field(:priceafterdiscount, :decimal)
    field(:qtyafterdisc, :integer)
    field(:quantity, :integer)
    field(:remark, :string)
    field(:tableid, :integer)
    field(:takeawayid, :string)
    field(:void_by, :integer)
    field(:voidreason, :string)
    field(:brand_id, :integer)
    field(:rowid, :integer)
    field(:void_datetime, :naive_datetime)
  end

  @doc false
  def changeset(void_items, attrs) do
    void_items
    |> cast(attrs, [
      :rowid,
      :itemcode,
      :itemname,
      :quantity,
      :price,
      :tableid,
      :itemid,
      :displayprice,
      :is_print,
      :discount,
      :priceafterdiscount,
      :qtyafterdisc,
      :itempriceperqty,
      :takeawayid,
      :discountitemsid,
      :remark,
      :is_void,
      :void_by,
      :voidreason,
      :orderid,
      :brand_id,
      :void_datetime
    ])
    |> validate_required([
      :itemcode,
      :itemname,
      :quantity,
      :price,
      :tableid,
      :itemid,
      :displayprice,
      :is_print,
      :discount,
      :priceafterdiscount,
      :qtyafterdisc,
      :itempriceperqty,
      :discountitemsid,
      :is_void,
      :void_by,
      :voidreason,
      :orderid
    ])
  end
end
