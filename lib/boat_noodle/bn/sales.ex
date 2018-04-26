defmodule BoatNoodle.BN.Sales do
  use Ecto.Schema
  import Ecto.Changeset


  schema "sales" do
    field :item_id, :integer
    field :quantity, :integer
    field :sales_master_id, :integer

    timestamps()
  end

  @doc false
  def changeset(sales, attrs) do
    sales
    |> cast(attrs, [:sales_master_id, :item_id, :quantity])
    |> validate_required([:sales_master_id, :item_id, :quantity])
  end
end
