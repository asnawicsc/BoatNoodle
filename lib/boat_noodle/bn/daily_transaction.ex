defmodule BoatNoodle.BN.DailyTransaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "daily_transations" do
    field(:file_serial_number, :string)
    field(:transation_date, :string)
    field(:sales_amount, :string)
    field(:branchid, :string)

    field(:sales_date, :date)
  end

  @doc false
  def changeset(sales, attrs) do
    sales
    |> cast(attrs, [
      :file_serial_number,
      :transation_date,
      :sales_amount,
      :sales_date,
      :branchid
    ])
  end
end
