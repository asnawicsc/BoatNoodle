defmodule BoatNoodle.BN.SalesPayment do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "salespayment" do
    field :after_disc, :decimal
    field :brand_id,:string
    field :card_no, :integer
    field :cash, :decimal
    field :changes, :decimal
    field :created_at, :string
    field :disc_amt, :decimal
    field :discountid, :string
    field :grand_total, :decimal
    field :gst_charge, :decimal
    field :payment_code1, :string
    field :payment_code2, :string
    field :payment_type, :string
    field :payment_name1, :string
    field :payment_name2, :string
    field :payment_type_amt1, :decimal
    field :payment_type_amt2, :decimal
    field :payment_type_id1, :integer
    field :payment_type_id2, :integer
    field :rounding, :decimal
    field :salesid, :string
    field :salespay_id, :integer, primary_key: true
    field :service_charge, :decimal
    field :sub_total, :decimal
    field :taxcode, :string
    field :updated_at, :string
    field :voucher_code, :string

  end

  @doc false
  def changeset(sales_payment, attrs) do
    sales_payment
    |> cast(attrs, [:salespay_id, :salesid, :sub_total,:payment_name2,:payment_name1, :brand_id, :after_disc, :service_charge, :gst_charge, :rounding, :grand_total, :cash, :changes, :payment_type, :card_no, :taxcode, :disc_amt, :voucher_code, :discountid, :payment_type_id1, :payment_type_amt1, :payment_code1, :payment_type_id2, :payment_type_amt2, :payment_code2, :updated_at, :created_at])
    end
end
