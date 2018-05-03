defmodule BoatNoodle.BN.CashierSession do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "cashier_session" do
    field :branchid, :string
    field :cash_in, :decimal
    field :cash_out, :decimal
    field :close_amt, :decimal
    field :csid, :integer, primary_key: true
    field :deposits, :decimal
    field :durations, :integer
    field :floatamt, :decimal
    field :open_amt, :decimal
    field :paidout, :decimal
    field :staffid, :string
    field :time_end, :utc_datetime
    field :time_start, :utc_datetime

  end

  @doc false
  def changeset(cashier_session, attrs) do
    cashier_session
    |> cast(attrs, [:csid, :staffid, :branchid, :time_start, :time_end, :floatamt, :open_amt, :close_amt, :cash_in, :cash_out, :durations, :deposits, :paidout])
   end
end
