defmodule BoatNoodle.BN.SalesMaster do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "salesdetail" do
    field :brand_id, :string
    field :itemcode, :string
    field :itemname, :string
    field :void_by, :string
    field :unit_price, :decimal
    field :sales_details, :integer, primary_key: true
    field :orderid, :string
    field :salesid, :string
    field :itemid, :integer
    field :itemcustomid, :string
    field :qty, :integer
    field :order_price, :decimal
    field :is_void, :integer
    field :voidreason, :string
    field :remark, :string
    field :combo_id, :integer
    field :discountid, :string
    field :afterdisc, :decimal
    field :remaks, :string
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime


  end

  @doc false
  def changeset(sales_master, attrs) do
    sales_master
    |> cast(attrs, [:brand_id,:itemcode,:itemname, :void_by,:unit_price, :updated_at,:created_at,:remaks,:afterdisc,:discountid,:combo_id,:remark,:voidreason,:is_void,:sales_details, :orderid, :salesid, :itemid, :itemcustomid, :qty,:order_price])
  end
end
