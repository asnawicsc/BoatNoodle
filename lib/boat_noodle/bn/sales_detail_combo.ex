defmodule BoatNoodle.BN.SalesDetailCombo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "sales_detail_combo" do
    field(:afterdisc, :decimal)
    field(:created_at, :utc_datetime)
    field(:is_combo_header, :integer)
    field(:is_void, :integer)
    field(:itemname, :string)
    field(:order_id, :string)
    field(:order_price, :decimal)
    field(:qty, :integer)
    field(:remark, :string)
    field(:sales_details_combo, :integer, primary_key: true)
    field(:sales_id, :string)
    field(:top_up, :decimal)
    field(:unit_price, :decimal, default: 0.00)
    field(:updated_at, :utc_datetime)
    field(:void_by, :string)
    field(:void_reason, :string)
    field(:brand_id, :integer, primary_key: true)
    field(:combo_name, :string)
    field(:catname, :string)
    field(:foc, :integer)
  end

  @doc false
  def changeset(sales_detail_combo, attrs) do
    sales_detail_combo
    |> cast(attrs, [
      :brand_id,
      :sales_details_combo,
      :order_id,
      :sales_id,
      :itemname,
      :qty,
      :order_price,
      :is_void,
      :void_by,
      :void_reason,
      :remark,
      :afterdisc,
      :unit_price,
      :created_at,
      :updated_at,
      :top_up,
      :is_combo_header,
      :combo_name,
      :catname,
      :foc
    ])
  end
end
