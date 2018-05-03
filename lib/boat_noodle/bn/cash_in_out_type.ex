defmodule BoatNoodle.BN.CashInOutType do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "cash_in_out_type" do
    field :cash_type_id, :integer, primary_key: true
    field :description, :string
    field :name, :string

  end

  @doc false
  def changeset(cash_in_out_type, attrs) do
    cash_in_out_type
    |> cast(attrs, [:cash_type_id, :name, :description])
 
  end
end
