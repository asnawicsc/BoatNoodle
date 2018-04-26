defmodule BoatNoodle.BN.PaymentType do
  use Ecto.Schema
  import Ecto.Changeset


  schema "payment_type" do
    field :payment_name, :string

    timestamps()
  end

  @doc false
  def changeset(payment_type, attrs) do
    payment_type
    |> cast(attrs, [:payment_name])
    |> validate_required([:payment_name])
  end
end
