defmodule BoatNoodle.BN.Sales do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "sales" do
    field(:salesid, :string, primary_key: true)
    field(:invoiceno, :string)
    field(:salesdate, :date)
    field(:salesdatetime, :naive_datetime)
    field(:tbl_no, :string)
    field(:pax, :integer)
    field(:branchid, :string)
    field(:staffid, :string)
    field(:type, :string)
    field(:is_void, :integer)
    field(:void_by, :string)
    field(:voidreason, :string)
    field(:remark, :string)
    field(:updated_at, :naive_datetime)
    field(:created_at, :naive_datetime)
    field(:brand_id, :integer, primary_key: true)
  end

  @doc false
  def changeset(sales, attrs) do
    sales
    |> cast(attrs, [
      :brand_id,
      :salesid,
      :invoiceno,
      :salesdate,
      :salesdatetime,
      :tbl_no,
      :pax,
      :branchid,
      :staffid,
      :type,
      :is_void,
      :void_by,
      :voidreason,
      :remark,
      :updated_at,
      :created_at
    ])
    |> validate_required([
      :brand_id,
      :salesid,
      :invoiceno,
      :salesdate,
      :salesdatetime,
      :tbl_no,
      :pax,
      :branchid,
      :staffid,
      :type
    ])
    |> unique_constraint(:salesid, name: "PRIMARY")
  end
end
