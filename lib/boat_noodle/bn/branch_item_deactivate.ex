defmodule BoatNoodle.BN.BranchItemDeactivate do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "branch_item_deactivate" do
    field :branchid, :integer, primary_key: true
    field :id, :integer
    field :is_activate, :integer
    field :itemid, :integer

  end

  @doc false
  def changeset(branch_item_deactivate, attrs) do
    branch_item_deactivate
    |> cast(attrs, [:id, :branchid, :itemid, :is_activate])

  end
end
