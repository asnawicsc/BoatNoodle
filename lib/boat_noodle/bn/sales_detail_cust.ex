defmodule BoatNoodle.BN.SalesDetailCust do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "salesdetailcust" do
    field :created_at, :utc_datetime
    field :custom_name, :string
    field :custom_price, :decimal
    field :orderid, :string
    field :salescustid, :integer, primary_key: true
    field :updated_at, :utc_datetime

  end

  @doc false
  def changeset(sales_detail_cust, attrs) do
    sales_detail_cust
    |> cast(attrs, [:salescustid, :orderid, :custom_name, :custom_price, :updated_at, :created_at])
    end
end
