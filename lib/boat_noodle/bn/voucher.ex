defmodule BoatNoodle.BN.Voucher do
  use Ecto.Schema
  import Ecto.Changeset

  schema "vouchers" do
    field(:branchid, :integer, default: 0)
    field(:code_number, :string)
    field(:discount_name, :string)
    field(:is_used, :boolean, default: false)
  end

  @doc false
  def changeset(voucher, attrs) do
    voucher
    |> cast(attrs, [:code_number, :discount_name, :is_used, :branchid])
    |> validate_required([:code_number, :discount_name, :is_used, :branchid])
  end
end

defmodule BoatNoodle.BN.VoucherCode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "vouchers" do
    field(:branchid, :integer, default: 0)
    field(:code, :string)
    field(:is_used, :boolean, default: 0)
  end

  @doc false
  def changeset(voucher, attrs) do
    voucher
    |> cast(attrs, [:code, :is_used, :branchid])
  end
end
