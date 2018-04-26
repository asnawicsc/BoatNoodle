defmodule BoatNoodle.BN.SalesMaster do
  use Ecto.Schema
  import Ecto.Changeset


  schema "sales_master" do
    field :casher, :string
    field :pax, :integer
    field :payment, :string
    field :receipt_no, :integer
    field :table, :integer
    field :total_amount, :decimal

    timestamps()
  end

  @doc false
  def changeset(sales_master, attrs) do
    sales_master
    |> cast(attrs, [:receipt_no, :payment, :total_amount, :table, :pax, :casher])
    |> validate_required([:receipt_no, :payment, :total_amount, :table, :pax, :casher])
  end
end
