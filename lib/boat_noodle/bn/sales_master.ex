defmodule BoatNoodle.BN.SalesMaster do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "salesdetail" do
    field(:brand_id, :integer, primary_key: true)
    field(:itemcode, :string)
    field(:itemname, :string)
    field(:void_by, :string)
    field(:unit_price, :decimal, default: 0.00)
    field(:sales_details, :integer, primary_key: true)
    field(:orderid, :string)
    field(:salesid, :string)
    field(:itemid, :integer)
    field(:itemcustomid, :string)
    field(:qty, :integer)
    field(:order_price, :decimal)
    field(:is_void, :integer)
    field(:voidreason, :string)
    field(:remark, :string)
    field(:combo_id, :integer)
    field(:discountid, :string)
    field(:afterdisc, :decimal)
    field(:remaks, :string)
    field(:created_at, :utc_datetime)
    field(:updated_at, :utc_datetime)

    field(:cat_type, :string)
    field(:cat_name, :string)
    field(:combo_name, :string)
    field(:final_nett_sales, :decimal)
    field(:total_combo_sub_item_qty, :integer)
    field(:combo_total_topup_qty, :decimal)
    field(:foc_qty, :integer)
    field(:discount_value, :decimal)
    field(:service_charge, :decimal)
    field(:salesdate, :date)
    field(:salesdatetime, :naive_datetime)
    field(:branchname, :string)
    field(:staffname, :string)
  end

  @doc false
  def changeset(sales_master, attrs) do
    sales_master
    |> cast(attrs, [
      :cat_type,
      :cat_name,
      :combo_name,
      :final_nett_sales,
      :total_combo_sub_item_qty,
      :combo_total_topup_qty,
      :foc_qty,
      :discount_value,
      :service_charge,
      :salesdate,
      :salesdatetime,
      :branchname,
      :staffname,
      :brand_id,
      :itemcode,
      :itemname,
      :void_by,
      :unit_price,
      :updated_at,
      :created_at,
      :remaks,
      :afterdisc,
      :discountid,
      :combo_id,
      :remark,
      :voidreason,
      :is_void,
      :sales_details,
      :orderid,
      :salesid,
      :itemid,
      :itemcustomid,
      :qty,
      :order_price
    ])
    |> validate_required([
      :brand_id,
      :itemname,
      :unit_price,
      :afterdisc,
      :discountid,
      :combo_id,
      :is_void,
      :orderid,
      :salesid,
      :itemid,
      :qty,
      :order_price
    ])
    |> unique_constraint(:sales_details, name: "PRIMARY")
  end
end

defmodule BoatNoodle.BN.SalesMaster_v1 do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "salesdetail" do
    field(:brand_id, :integer, primary_key: true)
    field(:itemcode, :string)
    field(:itemname, :string)
    field(:void_by, :string)
    field(:unit_price, :decimal, default: 0.00)
    field(:sales_details, :integer, primary_key: true)
    field(:orderid, :string)
    field(:salesid, :string)
    field(:itemid, :integer)
    field(:itemcustomid, :string)
    field(:qty, :integer)
    field(:order_price, :decimal)
    field(:is_void, :integer)
    field(:voidreason, :string)
    field(:remark, :string)
    field(:combo_id, :integer)
    field(:discountid, :string)
    field(:afterdisc, :decimal)
    field(:remaks, :string)
    field(:created_at, :utc_datetime)
    field(:updated_at, :utc_datetime)
  end

  @doc false
  def changeset(sales_master, attrs) do
    sales_master
    |> cast(attrs, [
      :brand_id,
      :itemcode,
      :itemname,
      :void_by,
      :unit_price,
      :updated_at,
      :created_at,
      :remaks,
      :afterdisc,
      :discountid,
      :combo_id,
      :remark,
      :voidreason,
      :is_void,
      :sales_details,
      :orderid,
      :salesid,
      :itemid,
      :itemcustomid,
      :qty,
      :order_price
    ])
    |> validate_required([
      :brand_id,
      :itemname,
      :unit_price,
      :afterdisc,
      :discountid,
      :combo_id,
      :is_void,
      :orderid,
      :salesid,
      :itemid,
      :qty,
      :order_price
    ])
    |> unique_constraint(:sales_details, name: "PRIMARY")
  end
end
