defmodule BoatNoodle.BN.CashInOut do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "cash_in_out" do
    field :id, :integer, primary_key: true
    field :branch_id, :integer
    field :date_time, :utc_datetime
    field :cashtype, :string
    field :staffid, :integer
    field :description, :string
    field :amount, :decimal
  field :brand_id, :integer

  end

  @doc false
  def changeset(cash_in_out, attrs) do
    cash_in_out
    |> cast(attrs, [
      :brand_id,
      :date_time,
       :amount,
       :branch_id, 
       :cashtype, 
       :staffid, 
       :description
       ])
     |> validate_required([      
      :brand_id,
      :date_time,
       :amount,
       :branch_id, 
       :cashtype, 
       :staffid, 
       :description
      ])
   |> unique_constraint(:id, name: "PRIMARY")
  end
end
