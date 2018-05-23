defmodule BoatNoodle.BN.CashInOut do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "cash_in_out" do
    field :id, :integer, primary_key: true
    field :branch_id, :integer
    field :date_time, :string
    field :cashtype, :string
    field :staffid, :integer
    field :description, :string
    field :amount, :decimal


  end

  @doc false
  def changeset(cash_in_out, attrs) do
    cash_in_out
    |> cast(attrs, [:amount,:id,:branch_id, :cashtype, :staffid, :description])
  end
end
