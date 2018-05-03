defmodule BoatNoodle.BN.RPTTRANSACTION do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "rpt_transaction" do
    field :after_disc, :decimal
    field :branchcode, :string
    field :branchid, :integer, primary_key: true
    field :cash, :decimal
    field :changes, :decimal
    field :grand_total, :decimal
    field :gst_charge, :decimal
    field :invoiceno, :string
    field :is_void, :integer
    field :pax, :integer
    field :payment_type, :string
    field :quarter, :integer
    field :remark, :string
    field :rounding, :decimal
    field :salesdate, :date
    field :saleshour, :integer
    field :salesid, :string
    field :salesmonth, :integer
    field :salestime, :utc_datetime
    field :salesyear, :integer
    field :service_charge, :decimal
    field :staffid, :integer
    field :staffname, :string
    field :sub_total, :decimal
    field :tbl_no, :integer
    field :type, :string
    field :void_by, :string
    field :voidreason, :string

  end

  @doc false
  def changeset(rpttransaction, attrs) do
    rpttransaction
    |> cast(attrs, [:salesid, :salesyear, :salesmonth, :salesdate, :saleshour, :salestime, :quarter, :branchid, :branchcode, :invoiceno, :sub_total, :after_disc, :decimal, :gst_charge, :service_charge, :rounding, :grand_total, :pax, :payment_type, :cash, :changes, :tbl_no, :type, :staffid, :staffname, :is_void, :void_by, :voidreason, :remark])
  end
end
