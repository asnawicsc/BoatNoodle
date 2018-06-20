defmodule BoatNoodle.BN.Sales do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "sales" do
    field :salesid, :string, primary_key: true
    field :invoiceno, :string
    field :salesdate, :date
    field :salesdatetime, :utc_datetime
    field :tbl_no, :string
    field :pax, :integer
    field :branchid, :string
    field :brand_id, :string, primary_key: true
    field :staffid, :string
    field :type, :string
    field :is_void, :integer
    field :void_by, :string
    field :voidreason, :string
    field :remark, :string
    field :updated_at, :utc_datetime
    field :created_at, :utc_datetime

  end

  @doc false
  def changeset(sales, attrs) do
    sales
    |> cast(attrs, [:salesid,:invoiceno,:salesdate,:brand_id,:salesdatetime,:tbl_no,:pax,:branchid,:staffid,:type,:is_void,:void_by,:voidreason,:remark,:updated_at,:created_at])
     end
end
