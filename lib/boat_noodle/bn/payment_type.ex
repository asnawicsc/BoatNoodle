defmodule BoatNoodle.BN.PaymentType do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "paymenttype" do
    field :payment_type_id, :integer, primary_key: true
    field :payment_type_name, :string
    field :payment_type_code, :string
    field :is_card_no, :integer
    field :is_payment_code, :integer
    field :is_default, :integer
    field :is_visible, :integer

  end

  @doc false
  def changeset(payment_type, attrs) do
    payment_type
    |> cast(attrs, [:is_visible,:is_default,:is_payment_code,:is_card_no,:payment_type_code,:payment_type_id,:payment_type_name])
  end
end
