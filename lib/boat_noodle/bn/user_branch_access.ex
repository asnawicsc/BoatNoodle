defmodule BoatNoodle.BN.UserBranchAccess do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "user_brnch_access" do
    field :branchid, :integer
    field :userbranchid, :integer
    field :userid, :integer, primary_key: true

  end

  @doc false
  def changeset(user_brnch_access, attrs) do
    user_brnch_access
    |> cast(attrs, [:userbranchid, :userid, :branchid])
  end
end
