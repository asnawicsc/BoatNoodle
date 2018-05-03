defmodule BoatNoodle.BN.RPTHOURLYOUTLET do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "rpt_hourly_outlet" do
    field :branchcode, :string
    field :branchid, :integer, primary_key: true
    field :branchname, :string
    field :pax, :integer
    field :sales, :decimal
    field :salesdate, :date
    field :saleshour, :integer
    field :salesmonth, :integer
    field :salesquarter, :integer
    field :salesyear, :integer
    field :transaction, :integer

  end

  @doc false
  def changeset(rpthourlyoutlet, attrs) do
    rpthourlyoutlet
    |> cast(attrs, [:salesyear, :salesmonth, :salesquarter, :salesdate, :branchid, :branchcode, :branchname, :saleshour, :sales, :pax, :transaction])
    end
end
