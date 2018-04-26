defmodule BoatNoodle.BN.CashInOut do
  use Ecto.Schema
  import Ecto.Changeset


  schema "cash_in_out" do
    field :branch, :string
    field :cash_in, :decimal
    field :cash_out, :decimal
    field :open_drawer, :integer

    timestamps()
  end

  @doc false
  def changeset(cash_in_out, attrs) do
    cash_in_out
    |> cast(attrs, [:branch, :cash_in, :cash_out, :open_drawer])
    |> validate_required([:branch, :cash_in, :cash_out, :open_drawer])
  end
end
